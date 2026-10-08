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
    // Breadcrumbs in the device log: iOS reclaiming a backgrounded scene
    // destroys the Flutter engine, and reopening builds a new one (see
    // _startupStep in main.dart).
    for name in [UIScene.willConnectNotification, UIScene.didDisconnectNotification] {
      NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { note in
        NSLog("[PlaygroundTracker] %@", note.name.rawValue)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    NSLog("[PlaygroundTracker] Flutter engine started")
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if CloudKitPlugin.isAvailable,
       let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CloudKitPlugin") {
      CloudKitPlugin.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CalendarBridge") {
      CalendarBridge.shared.register(with: registrar.messenger())
    }
    // TEMPORARY test hook (Settings › Diagnostics): asks iOS to reclaim the
    // scene the way it does in the background under memory pressure, so the
    // reopen path can be tried on demand. Remove once that path is verified.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SceneReclaimTest") {
      let channel = FlutterMethodChannel(
        name: "com.playground.tracker/diagnostics", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        guard call.method == "reclaimScene",
              let session = UIApplication.shared.connectedScenes.first?.session else {
          result(FlutterMethodNotImplemented)
          return
        }
        result(nil)
        NSLog("[PlaygroundTracker] reclaiming the scene (test)")
        UIApplication.shared.requestSceneSessionDestruction(session, options: nil) { error in
          NSLog("[PlaygroundTracker] scene reclaim failed: %@", error.localizedDescription)
        }
      }
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
