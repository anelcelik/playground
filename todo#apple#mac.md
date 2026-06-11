# 🍎 Mac Checklist — Playground Tracker on iPhone

Everything below is the Apple-side work that cannot be done on Linux.
Work top to bottom — each step depends on the previous one.

**Good news:** the Xcode project in `IOS/ios/` is fully committed and wired.
CloudKitPlugin.swift is compiled into the app, the entitlements
(iCloud container + push) exist, background sync mode is set, minimum iOS
is 15.0. There is **nothing to generate, copy, or configure by hand** —
the old "run flutter create and copy Swift files" workflow is gone.

---

## 1. Install the tools

| Tool | How |
|------|-----|
| **Xcode** | Mac App Store → "Xcode" → Install (~15 GB). Open it once, accept the license, let it install components. |
| **Flutter** | https://docs.flutter.dev/get-started/install/macos — or copy `IOS/flutter/` from the Linux machine and add `flutter/bin` to PATH. |
| **CocoaPods** | Only if the build asks for it: `sudo gem install cocoapods`. The project uses Swift Package Manager, so it may not be needed at all. |

Verify:
```bash
flutter doctor
```
Fix anything red before continuing (yellow warnings are fine).

---

## 2. Get the code and dependencies

```bash
git clone https://github.com/anelcelik/playground.git
cd playground/IOS
flutter pub get
```

---

## 3. Apple Developer account — required for sync

CloudKit/iCloud entitlements **do not work with a free personal team**.
For family sync between devices you need the paid Apple Developer Program
($99/year): https://developer.apple.com

> No paid account (yet)? You can still run the app on your own iPhone with
> a free team — but you must open the project in Xcode and **remove the
> iCloud + Push capabilities** (Signing & Capabilities → ✕ on each),
> otherwise signing fails. Sync will show the grey "not available" dot;
> everything else works. Re-add the capabilities once you have the account.

---

## 4. Open in Xcode and sign

```bash
open ios/Runner.xcworkspace        # the .xcworkspace, never the .xcodeproj
```

1. Click **Runner** at the top of the project navigator.
2. Select the **Runner** target → **Signing & Capabilities** tab.
3. **Team** → select your developer team.
4. Verify the capabilities are already listed (they come from
   `Runner/Runner.entitlements`):
   - iCloud → CloudKit → container `iCloud.com.playground.tracker`
   - Push Notifications
   - Background Modes → Remote notifications
5. If Xcode complains the iCloud container doesn't exist, press the
   **refresh/fix button** under the capability — Xcode registers the
   container on your developer account automatically.

---

## 5. First run on your iPhone

1. Plug in the iPhone via USB → tap **Trust** on the phone.
2. On the phone: Settings → Privacy & Security → Developer Mode → on
   (iOS 16+; phone reboots).
3. Then either press ▶ in Xcode, or:

```bash
flutter devices          # confirm the phone is listed
flutter run -d <device-id>
```

First launch on the phone: Settings → General → VPN & Device Management →
trust your developer certificate.

---

## 6. Verify CloudKit sync works

The CloudKit code was written and reviewed on Linux but **never compiled by
Xcode** — if anything in `CloudKitPlugin.swift`, `AppDelegate.swift`, or
`SceneDelegate.swift` fails to build, the errors will be small API
mismatches and easy to fix in place.

Once running, on a phone signed into iCloud:

- [ ] Sync dot in the app bar turns **green** within a few seconds.
- [ ] Add an entry → check the CloudKit Console
      (https://icloud.developer.apple.com → container
      `iCloud.com.playground.tracker` → Development environment →
      Records): a `PlaygroundEntry` record appears in zone `PlaygroundZone`.
- [ ] **Edit** the entry → record's `last_modified` updates in the console
      (this is the bug that was fixed — updates used to be silently dropped).
- [ ] Delete the entry → record shows `is_deleted = 1`.

### Family sharing (needs the second phone / second Apple ID)

- [ ] Phone A: ⚙️ → Family Sync → invite → send link via iMessage/WhatsApp.
- [ ] Phone B taps the link → iOS shows "Open with Playground Tracker" →
      accept. (Handled by `SceneDelegate.userDidAcceptCloudKitShareWith`.)
- [ ] Entry created on A appears on B — should arrive within seconds via
      silent push; worst case on next app-foreground or the 3-minute timer.
- [ ] Notifications screen: allow notifications → reminders fire.

---

## 7. Before TestFlight / App Store (later)

- [ ] **Deploy the CloudKit schema to Production.** Record types are
      auto-created in the *Development* environment while you test. In the
      CloudKit Console: container → Schema → **Deploy Schema Changes** to
      Production. Without this, the App Store build syncs nothing.
- [ ] Bump `version:` in `IOS/pubspec.yaml`.
- [ ] Archive in Xcode (Product → Archive) — Xcode flips the
      `aps-environment` entitlement to production automatically.

---

## Reference

- CI builds an **unsigned** IPA on every push touching `IOS/`
  (GitHub → Actions → "Build iOS IPA (unsigned)") — useful as a compile
  check for the Swift code even before you have the Mac.
- Sync design notes: `IOS/README.md`.
