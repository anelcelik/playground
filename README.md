# 🌳 Playground Tracker

A private family app to track daily playground outings — who went, when, how long, what the kids did, and why nobody went.

---

## Platform overview

| Feature | iOS | Android |
|---------|:---:|:-------:|
| **Log Entry** — morning / evening / vacation / no playground | ✅ | ✅ |
| **Reasons for no playground** (Rain, Sick, etc.) | ✅ | ✅ |
| **Dashboard** — stats, charts, log | ✅ | ✅ |
| **Customisable dashboard layout** (drag & hide sections) | ✅ | ✅ |
| **Recurring activities** (weekly schedule) | ✅ | ✅ |
| **Recurring activity notifications** (per-activity reminder) | ✅ | ✅ |
| **Daily reminders** (outdoor + log-entry) | ✅ | ✅ |
| **Date & time format settings** (EU / US, 12h / 24h) | ✅ | ✅ |
| **Family setup** (unlimited parents, kids, grandparents) | ✅ | ✅ |
| **Local SQLite storage** — fully offline | ✅ | ✅ |
| **App icon** | ✅ | ✅ |
| **CloudKit sync** between different Apple IDs | ✅ | ❌ |
| **Family invite** (share link, multi-device) | ✅ | ❌ |
| **Multi-user sync** | ✅ | ❌ Single user only |
| **Install without developer account** | ❌ Needs $99/yr | ✅ Sideload APK |
| **Build via GitHub Actions** | ✅ unsigned `.app` | ✅ debug `.apk` |
| **Minimum OS** | iOS 15.0 | Android 5.0 (API 21) |

---

## Folder structure

```
playground/
├── IOS/                        Flutter iOS app (primary)
│   ├── lib/                    Dart source — all screens & logic
│   ├── assets/icon.png         1024×1024 app icon
│   ├── swift/
│   │   ├── CloudKitPlugin.swift   Native CloudKit sync (copy to ios/Runner/)
│   │   └── AppDelegate.swift      Modified AppDelegate (copy to ios/Runner/)
│   └── pubspec.yaml
│
├── ANDROID/                    Flutter Android app (same Dart code, no sync)
│   ├── lib/                    Identical Dart source to IOS/lib/
│   ├── assets/icon.png         Same icon
│   └── pubspec.yaml
│
├── WebServerApp/               Original Python/Flask PWA (unchanged)
│   ├── app.py
│   └── static/
│
├── .github/workflows/
│   ├── ios.yml                 Builds unsigned Runner.app (macos-latest)
│   └── android.yml             Builds debug APK (ubuntu-latest)
│
└── todo#apple#mac.md           Step-by-step Mac/Xcode setup guide
```

---

## Getting a build

### Android — no accounts needed

1. Push to `main` → GitHub Actions builds automatically
2. Go to **Actions → Build Android APK → latest run → Artifacts**
3. Download `playground-tracker-android-debug-xxx.zip` → extract the `.apk`
4. On your phone: **Settings → Apps → Special app access → Install unknown apps** → allow
5. Tap the APK to install

### iOS — Mac required

See **`todo#apple#mac.md`** for the full step-by-step guide. Summary:

1. Mac + Xcode + CocoaPods
2. `flutter create --platforms ios .` inside `IOS/`
3. Copy `swift/CloudKitPlugin.swift` + `swift/AppDelegate.swift` → `ios/Runner/`
4. Add CloudKit capability in Xcode (container: `iCloud.com.playground.tracker`)
5. Set minimum iOS 15.0
6. `flutter run -d YOUR_IPHONE` via USB — no TestFlight needed for personal use

---

## What CloudKit sync does (iOS only)

- Every save/delete pushes to your private CloudKit zone immediately
- App fetches changes every 30 seconds and on foreground
- **Different Apple IDs supported** — owner taps ⚙️ → Family Sync → Invite Someone, sends a link, partner accepts → both sync automatically
- Merge rule: `last_modified` timestamp wins; ties go to the local device
- Soft deletes propagate across devices

---

## Local preview on Linux (no iOS device needed)

```bash
cd IOS
./flutter/bin/flutter run -d linux
```

Runs the full app as a Linux desktop window — all features work except CloudKit sync (shows grey dot).

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.x / Dart 3.x |
| Local storage | SQLite via `sqflite` |
| iOS sync | CloudKit (CKShare zone, per-device files) via MethodChannel |
| Notifications | `flutter_local_notifications` |
| Icons | `flutter_launcher_icons` from `assets/icon.png` |
| CI | GitHub Actions — `macos-latest` (iOS), `ubuntu-latest` (Android) |
| Original PWA | Python Flask + vanilla JS (in `WebServerApp/`) |
