import CloudKit
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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CloudKitPlugin") {
      CloudKitPlugin.register(with: registrar)
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
