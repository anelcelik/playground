# ✅ Mac / Xcode — What You Still Need To Do

Everything in this file is the Apple-side work that cannot be done on Linux.
Work through it top to bottom — each section depends on the previous one.

---

## 1. Install the tools on Mac

| Tool | How |
|------|-----|
| **Xcode** | Mac App Store → search "Xcode" → Install (≈ 15 GB, takes a while) |
| **Xcode Command Line Tools** | After Xcode opens, it will prompt you — accept |
| **Flutter SDK** | Copy the `IOS/flutter/` folder from your Linux machine, OR download fresh from https://docs.flutter.dev/get-started/install/macos |
| **CocoaPods** | Open Terminal → `sudo gem install cocoapods` |

Verify everything works:
```bash
flutter doctor
```
All checkmarks should be green (or at worst yellow warnings). Fix any red ones before continuing.

---

## 2. Get dependencies (iOS project is already committed)

The `IOS/ios/` Xcode project is checked into the repo and already contains:
- `CloudKitPlugin.swift` (compiled into the Runner target via the project file)
- the CloudKit-aware `AppDelegate.swift` + `SceneDelegate.swift`
- `Runner.entitlements` with the iCloud container `iCloud.com.playground.tracker`
  and push entitlement, wired via `CODE_SIGN_ENTITLEMENTS`
- minimum iOS set to 15.0 and the `remote-notification` background mode

So do **not** run `flutter create` and do **not** copy any Swift files —
that old workflow is gone. Just:

```bash
cd IOS
flutter pub get
```

(If the build asks for CocoaPods: `cd ios && pod install && cd ..`)

---

## 3. Apple Developer Account

You need a paid Apple Developer account ($99/year) for:
- iCloud entitlements
- Installing on real devices
- TestFlight

Sign up or log in at: **https://developer.apple.com**

---

## 4. Open the project in Xcode

```bash
open ios/Runner.xcworkspace
```

⚠️ Always open the `.xcworkspace` file, **never** the `.xcodeproj` file — the workspace includes CocoaPods.

---

## 5. Set your Team & Bundle ID

1. In Xcode left sidebar → click **Runner** (top of the project tree)
2. Select target **Runner**
3. Tab: **Signing & Capabilities**
4. Set **Team** → your Apple Developer account
5. Confirm **Bundle Identifier** is `com.playground.tracker`
   - If Xcode shows a red error about identifier already taken → change it to something unique like `com.yourname.playgroundtracker` and also update `_kContainerId` in `IOS/lib/sync/sync_service.dart` to match

---

## 6. Add CloudKit capability

Still in **Signing & Capabilities**:

1. Click **+ Capability** → search **iCloud** → double-click to add it
2. In the iCloud section:
   - Check ✅ **CloudKit** ← this is the important one
   - Check ✅ **iCloud Documents** (keep it on)
   - Under **Containers** click **+** → type `iCloud.com.playground.tracker` → OK
3. Click **+ Capability** again → search **Background Modes** → add it
   - Check ✅ **Remote notifications** (needed for CloudKit push notifications of changes)

Xcode will automatically create the container in your Apple Developer account.

⚠️ **You only need to do this once** — every device that installs the app uses the same container.

---

## 7. Set minimum iOS version

1. Still on target **Runner** → tab **General**
2. Under **Minimum Deployments** → set iOS to **15.0**
   (CloudKit zone sharing requires iOS 15+; flutter_local_notifications requires iOS 13+)

---

## 8. Run on iOS Simulator (free, no account needed)

```bash
# List available simulators
flutter devices

# Run on a simulator (example)
flutter run -d "iPhone 16"
```

What to verify on the simulator:
- [ ] App opens and shows family setup screen on first launch
- [ ] Can add parents and kids
- [ ] Log Entry tab works — save entries, delete entries
- [ ] Dashboard shows stats and charts
- [ ] Notifications screen opens — toggle switches and time picker work
- [ ] No crashes

⚠️ iCloud sync will **not** work on the simulator — it needs a real signed-in device.
Notifications **do** work on the simulator.

---

## 9. Run on a real iPhone

1. Plug your iPhone into the Mac with USB
2. On the iPhone: trust this computer when prompted
3. In Xcode: select your iPhone as the run destination (top bar)
4. Run:
   ```bash
   flutter run -d YOUR_DEVICE_ID
   ```
   Or just press **▶ Run** in Xcode

What to verify on device:
- [ ] App installs and opens
- [ ] Sign in to iCloud on the device (Settings → Apple ID) if not already
- [ ] Save an entry → sync dot turns 🟡 then 🟢
- [ ] Check iCloud Drive on Mac (Finder → iCloud Drive) — you should see a file called `playground_sync_<uuid>.json`
- [ ] Notifications permission dialog appears when you open Notifications screen
- [ ] Set a test reminder 2 minutes from now → confirm it fires

---

## 9b. Set up family sharing (different Apple IDs) — CloudKit

This is the key difference from the old icloud_storage approach.
**Each family member uses their own Apple ID.**

### Owner setup (your iPhone (owner))

The app exposes a "Share with family" button — you need to add it to the Settings screen
or call `SyncService.instance.createShareLink()` from a button.

Quick way to trigger it — add a temporary debug button anywhere and call:
```dart
final url = await SyncService.instance.createShareLink();
// Show url in a dialog or copy to clipboard
```

This generates a URL like `https://www.icloud.com/cloudkit/share/...`

Send that URL to your partner / grandma via WhatsApp or iMessage.

### Partner setup (different Apple ID)

1. Partner taps the link on their iPhone
2. iOS shows a system dialog: **"Join Playground Tracker?"** → tap **Accept**
3. That's it — their app now reads and writes to the same CloudKit zone

### What happens after accepting

- Owner writes to their **private CloudKit database**
- Partner writes to the **shared CloudKit database** (same zone, different path)
- The Swift plugin auto-detects which database to use on each device
- Both see the same entries within 30 seconds

### Revoke access

If you want to stop sharing with someone, go to:
**iOS Settings → [Your Name] → iCloud → Manage Account Storage → Sharing** → remove the share.

---

## 10. Test CloudKit sync between two iPhones

Both iPhones can use **different Apple IDs** — that's the whole point.

1. Install app on iPhone A (yours) and iPhone B (partner / grandma)
2. On iPhone A: add some entries
3. Wait up to 30 seconds OR background and foreground the app on iPhone B
4. Check iPhone B → entries from A should appear

What to verify:
- [ ] Entry created on A appears on B
- [ ] Entry deleted on A disappears on B (soft delete)
- [ ] Both edit the same entry at different times → newer one wins
- [ ] One phone goes offline → app still works → comes back online → catches up
- [ ] Three devices sync correctly (if testing with grandma's phone too)

If you change the family setup (add a new kid, rename a parent) on one phone → the other should receive it within 30 seconds.

---

## 11. GitHub Actions — iOS build in CI

The workflow at `.github/workflows/ios.yml` already exists.

To trigger it:
```bash
git add .
git commit -m "Add iOS Flutter app"
git push origin main
```

Go to **github.com → your repo → Actions** tab → watch the build.

The first run will:
1. Run on a `macos-latest` GitHub runner
2. Generate iOS project files
3. Run `flutter pub get` + `pod install`
4. Build `Runner.app` (unsigned — for test only)
5. Upload it as a build artifact you can download

⚠️ The unsigned `.app` from CI **cannot be installed** on a device — it is only useful to confirm the code compiles. For actual device installs → use Xcode directly (step 9).

---

## 12. (Optional) Distribute via TestFlight

When you are ready to share with family without a USB cable:

1. In Xcode → **Product → Archive**
2. Xcode Organizer opens → click **Distribute App**
3. Choose **App Store Connect** → **TestFlight Internal Testing**
4. Follow the upload wizard — it handles signing automatically
5. Go to **https://appstoreconnect.apple.com**
6. Add testers by email (family members)
7. They install **TestFlight** from the App Store, then tap the invite link

---

## Quick reference — files to be aware of

| File | What it controls |
|------|-----------------|
| `IOS/lib/sync/sync_service.dart` | Flutter MethodChannel — calls Swift CloudKit plugin |
| `IOS/swift/CloudKitPlugin.swift` | All CloudKit logic — copy to `ios/Runner/` and add to Xcode target |
| `IOS/swift/AppDelegate.swift` | Modified AppDelegate — registers CloudKit plugin |
| `IOS/swift/CloudKitPlugin.swift` line 16 | Container ID — must match Xcode capability |
| `.github/workflows/ios.yml` | CI build — triggers on push to `main` when `IOS/**` changes |
| `ios/Runner.xcworkspace` | Always open this in Xcode, never `.xcodeproj` |

---

## 12. Signed IPA via GitHub Actions (optional — when ready to distribute)

The CI workflow already builds an **unsigned** `.app` on every push.
This is enough to verify the code compiles.

For a **real installable IPA** (TestFlight / Ad Hoc), uncomment the
`build-ipa` job in `.github/workflows/ios.yml` and add these secrets
in **GitHub → repo → Settings → Secrets and variables → Actions**:

| Secret name | How to get it |
|---|---|
| `IOS_CERTIFICATE_BASE64` | Export Distribution certificate from Keychain Access as `.p12` → `base64 -i cert.p12` |
| `IOS_CERTIFICATE_PASSWORD` | The password you set when exporting the `.p12` |
| `IOS_PROVISION_PROFILE_BASE64` | Download `.mobileprovision` from Apple Developer portal → `base64 -i profile.mobileprovision` |
| `KEYCHAIN_PASSWORD` | Any random string |

Then the CI will produce a signed `.ipa` artifact ready for TestFlight upload.

---

## Summary checklist

### On Mac (do once)
- [ ] Xcode + CocoaPods installed
- [ ] `flutter create --platforms ios .` run inside `IOS/`
- [ ] `pod install` run inside `IOS/ios/`
- [ ] `swift/CloudKitPlugin.swift` copied to `ios/Runner/` and added to Xcode target
- [ ] `swift/AppDelegate.swift` copied to `ios/Runner/` (replaces generated one)
- [ ] Bundle ID set — `com.playground.tracker`
- [ ] **CloudKit** capability added + container `iCloud.com.playground.tracker`
- [ ] Background Modes → Remote notifications enabled
- [ ] Minimum iOS version set to **15.0** (CloudKit zone sharing requirement)
- [ ] Tested on simulator — UI works, notifications work
- [ ] Tested on real iPhone — sync dot turns green

### Family sharing (do once, from the owner's iPhone)
- [ ] Owner calls `createShareLink()` from Settings → gets a URL
- [ ] URL sent via WhatsApp / iMessage to partner / grandma
- [ ] Partner taps link → iOS shows "Accept" dialog → accepts
- [ ] Both devices sync within 30 seconds

### CI / distribution
- [ ] GitHub Actions `build-ios` job passes (unsigned `.app` artifact)
- [ ] (Optional) Add signing secrets → uncomment `build-ipa` job → signed IPA artifact
- [ ] (Optional) Upload IPA to TestFlight for wireless distribution
