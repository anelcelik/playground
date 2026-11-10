import CloudKit
import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  // The invitation link opened the app from closed: the accepted share comes
  // with the launch, not through userDidAcceptCloudKitShareWith below.
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    if let metadata = connectionOptions.cloudKitShareMetadata {
      CloudKitPlugin.userAcceptedShare(metadata)
    }
  }

  // Called by iOS when the user taps an iCloud share link and accepts the
  // share while the app is running. With the UIScene lifecycle this arrives
  // here, NOT on AppDelegate.
  override func windowScene(
    _ windowScene: UIWindowScene,
    userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
  ) {
    CloudKitPlugin.userAcceptedShare(cloudKitShareMetadata)
  }
}
