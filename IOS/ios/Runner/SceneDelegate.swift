import CloudKit
import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  // Called by iOS when the user taps an iCloud share link and accepts the
  // share. With the UIScene lifecycle this arrives here, NOT on AppDelegate.
  override func windowScene(
    _ windowScene: UIWindowScene,
    userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
  ) {
    CloudKitPlugin.shared?.acceptShare(metadata: cloudKitShareMetadata)
  }
}
