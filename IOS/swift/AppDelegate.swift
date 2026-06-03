// AppDelegate.swift — replace ios/Runner/AppDelegate.swift with this file
// after running `flutter create --platforms ios .`

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Register the CloudKit MethodChannel plugin
        if let registrar = self.registrar(forPlugin: "CloudKitPlugin") {
            CloudKitPlugin.register(with: registrar)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Handle incoming iCloud share URLs (tapped by the family member who received the link)
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme?.hasPrefix("cloudkit-") == true {
            CloudKitPlugin().handleIncomingShareURL(url)
            return true
        }
        return super.application(app, open: url, options: options)
    }
}
