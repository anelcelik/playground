import CloudKit
import EventKit
import EventKitUI
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Needed for CloudKit silent pushes (CKDatabaseSubscription).
    // Silent pushes require no user permission dialog.
    application.registerForRemoteNotifications()
    NativeDiagLog.start()
    ResumeCover.shared.install()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    NativeDiagLog.log("Flutter engine started")
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if CloudKitPlugin.isAvailable,
       let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CloudKitPlugin") {
      CloudKitPlugin.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CalendarBridge") {
      CalendarBridge.shared.register(with: registrar.messenger())
    }
  }

  // CloudKit sends a silent push when the other device changes synced data
  // (via the CKDatabaseSubscription created in CloudKitPlugin).
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if let dict = userInfo as? [String: Any],
       let note = CKNotification(fromRemoteNotificationDictionary: dict),
       note.notificationType == .database {
      CloudKitPlugin.shared?.notifyRemoteChange()
      completionHandler(.newData)
      return
    }
    super.application(application, didReceiveRemoteNotification: userInfo,
                      fetchCompletionHandler: completionHandler)
  }
}

// "Add to Calendar" for plans (lib/services/calendar_service.dart): opens iOS's
// own New Event sheet, prefilled. Apps cannot send invitations themselves; the
// sheet's Invitees row does. From iOS 17 the sheet runs out of process and
// needs no calendar permission; before that it needs full access.
final class CalendarBridge: NSObject, EKEventEditViewDelegate {
  static let shared = CalendarBridge()
  private let store = EKEventStore()
  private var pending: FlutterResult?

  func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.playground.tracker/calendar", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "addEvent", let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      CalendarBridge.shared.addEvent(args, result: result)
    }
  }

  private func addEvent(_ args: [String: Any], result: @escaping FlutterResult) {
    if #available(iOS 17.0, *) {
      present(args, result: result)
      return
    }
    store.requestAccess(to: .event) { granted, _ in
      DispatchQueue.main.async {
        if granted {
          self.present(args, result: result)
        } else {
          result("denied")
        }
      }
    }
  }

  private func present(_ args: [String: Any], result: @escaping FlutterResult) {
    guard pending == nil, let top = CalendarBridge.topViewController() else {
      result("unavailable")
      return
    }
    func number(_ key: String) -> Double? { (args[key] as? NSNumber)?.doubleValue }

    let event = EKEvent(eventStore: store)
    event.title = args["title"] as? String
    event.notes = args["notes"] as? String
    let start = Date(timeIntervalSince1970: (number("startMs") ?? 0) / 1000)
    event.startDate = start
    event.endDate = start.addingTimeInterval((number("durationMin") ?? 60) * 60)
    if let days = args["weekdays"] as? [NSNumber], !days.isEmpty {
      // Dart 0 = Mon … 6 = Sun; EKWeekday 1 = Sun … 7 = Sat.
      let weekdays = days.compactMap { EKWeekday(rawValue: ($0.intValue + 1) % 7 + 1) }
      var end: EKRecurrenceEnd?
      if let until = number("untilMs") {
        end = EKRecurrenceEnd(end: Date(timeIntervalSince1970: until / 1000))
      }
      event.recurrenceRules = [
        EKRecurrenceRule(
          recurrenceWith: .weekly,
          interval: 1,
          daysOfTheWeek: weekdays.map { EKRecurrenceDayOfWeek($0) },
          daysOfTheMonth: nil,
          monthsOfTheYear: nil,
          weeksOfTheYear: nil,
          daysOfTheYear: nil,
          setPositions: nil,
          end: end)
      ]
    }

    let editor = EKEventEditViewController()
    editor.eventStore = store
    editor.event = event
    editor.editViewDelegate = self
    pending = result
    top.present(editor, animated: true)
  }

  func eventEditViewController(
    _ controller: EKEventEditViewController,
    didCompleteWith action: EKEventEditViewAction
  ) {
    controller.dismiss(animated: true)
    pending?(action == .saved ? "saved" : "cancelled")
    pending = nil
  }

  private static func topViewController() -> UIViewController? {
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

// Native half of the diagnostics log (Dart half: lib/services/diag_log.dart).
// Scene and app events go to Documents/diagnostics-native.log, pulled over USB
// when the app came back from the background as a white screen. Writes are
// serialised on a background queue and never throw.
enum NativeDiagLog {
  private static let queue = DispatchQueue(label: "playground.diaglog")
  private static let url = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask).first?
    .appendingPathComponent("diagnostics-native.log")
  private static let stamp: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
  }()

  static func start() {
    queue.async {
      // Rolling: start over past 256 KB.
      if let url = url,
         let size = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.size] as? Int,
         size > 256 * 1024 {
        try? FileManager.default.removeItem(at: url)
      }
    }
    log("process launched")
    let names: [Notification.Name] = [
      UIScene.willConnectNotification, UIScene.didDisconnectNotification,
      UIScene.willEnterForegroundNotification, UIScene.didActivateNotification,
      UIScene.willDeactivateNotification, UIScene.didEnterBackgroundNotification,
      UIApplication.didReceiveMemoryWarningNotification, UIApplication.willTerminateNotification,
      UIApplication.protectedDataWillBecomeUnavailableNotification,
      UIApplication.protectedDataDidBecomeAvailableNotification,
    ]
    for name in names {
      NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { note in
        log(note.name.rawValue)
      }
    }
  }

  static func log(_ message: String) {
    let line = "\(stamp.string(from: Date())) [\(getpid())] \(message)\n"
    queue.async {
      guard let url = url, let data = line.data(using: .utf8) else { return }
      if let handle = try? FileHandle(forWritingTo: url) {
        handle.seekToEndOfFile()
        handle.write(data)
        handle.closeFile()
      } else {
        try? data.write(to: url)
      }
    }
  }
}

// FlutterViewController drops its drawing surface when the scene enters the
// background and recreates it only once the scene is active again
// (appOrSceneBecameActive). Until then the bare view shows: the white seen in
// the app switcher, during the return animation, and for as long as the scene
// stays inactive (Face ID, banners). ResumeCover lays a snapshot of the last
// frame over the Flutter view as the scene deactivates, and lifts it once
// Flutter is displaying UI again — or after 5 s regardless, so a real stall
// still shows (and is logged).
final class ResumeCover: NSObject {
  static let shared = ResumeCover()

  private var cover: UIView?
  private weak var watched: FlutterViewController?
  private var watchdog: DispatchWorkItem?
  private var coveredAt = Date()

  func install() {
    let center = NotificationCenter.default
    center.addObserver(forName: UIScene.willDeactivateNotification, object: nil, queue: .main) {
      [weak self] note in self?.coverIfShowingUI(note.object as? UIWindowScene)
    }
    center.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: .main) {
      [weak self] _ in self?.sceneActivated()
    }
  }

  private func flutterViewController(_ scene: UIWindowScene?) -> FlutterViewController? {
    let window = scene?.windows.first { $0.isKeyWindow } ?? scene?.windows.first
    return window?.rootViewController as? FlutterViewController
  }

  private func coverIfShowingUI(_ scene: UIWindowScene?) {
    guard cover == nil, let vc = flutterViewController(scene), vc.isDisplayingFlutterUI,
          let snapshot = vc.view.snapshotView(afterScreenUpdates: false) else { return }
    snapshot.frame = vc.view.bounds
    snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    vc.view.addSubview(snapshot)
    cover = snapshot
    coveredAt = Date()
    if watched !== vc {
      watched?.removeObserver(self, forKeyPath: "displayingFlutterUI")
      vc.addObserver(self, forKeyPath: "displayingFlutterUI", options: [.new], context: nil)
      watched = vc
    }
  }

  private func sceneActivated() {
    guard cover != nil else { return }
    if watched?.isDisplayingFlutterUI == true {
      // Never lost its surface (Control Center, a banner): nothing to wait for.
      lift("active, UI still on screen")
      return
    }
    watchdog?.cancel()
    let item = DispatchWorkItem { [weak self] in self?.lift("FLUTTER UI NOT BACK 5s after activate") }
    watchdog = item
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: item)
  }

  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?,
    change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?
  ) {
    guard keyPath == "displayingFlutterUI", (change?[.newKey] as? Bool) == true else { return }
    DispatchQueue.main.async { [weak self] in self?.lift("Flutter UI back") }
  }

  private func lift(_ reason: String) {
    guard let view = cover else { return }
    cover = nil
    watchdog?.cancel()
    watchdog = nil
    let ms = Int(Date().timeIntervalSince(coveredAt) * 1000)
    NativeDiagLog.log("resume cover lifted after \(ms) ms: \(reason)")
    UIView.animate(withDuration: 0.15, animations: { view.alpha = 0 }) { _ in view.removeFromSuperview() }
  }
}
