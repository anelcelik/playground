# Playground Tracker — iOS (Flutter)

Family playground visit tracker: who went, when, how long, what the kids did,
and why nobody went. Fully local SQLite storage with optional CloudKit sync
between family members (works across different Apple IDs).

The Android variant lives in `../ANDROID/`; see the repo root README for the
feature matrix.

## Layout

| Path | What it is |
|------|------------|
| `lib/` | All Dart code (screens, models, db, sync, notifications) |
| `ios/` | Committed Xcode project — includes `CloudKitPlugin.swift`, CloudKit-aware `AppDelegate`/`SceneDelegate`, `Runner.entitlements` |
| `test/` | Unit tests (sync merge rules, models) + widget smoke tests |
| `assets/icon.png` | 1024×1024 source icon (`dart run flutter_launcher_icons`) |

## Develop on Linux (no Mac needed)

```bash
flutter pub get
flutter run -d linux       # full app; CloudKit sync shows as unavailable
flutter test               # merge rules, models, widget smoke tests
flutter analyze
```

## Build for iPhone (Mac + Xcode)

The iOS project is fully wired in this repo — nothing to copy or generate:

1. `flutter pub get`
2. Open `ios/Runner.xcworkspace` in Xcode → **Signing & Capabilities** →
   select your team. The CloudKit container `iCloud.com.playground.tracker`
   and push entitlement are already in `Runner.entitlements`.
3. `flutter run -d <your-iphone>` over USB.

Unsigned CI builds: GitHub Actions (`.github/workflows/ios.yml`) produces an
unsigned IPA artifact on every push touching `IOS/`.

## How sync works

- SQLite is the source of truth; every entry has a `uuid`, `last_modified`
  (Unix ms) and an `is_deleted` tombstone.
- A `needs_push` flag marks locally changed rows; sync pushes only those,
  batched into one `CKModifyRecordsOperation` (savePolicy `.changedKeys`).
- Sync order is fetch → merge → push. Merge rule: newer `last_modified`
  wins, ties keep the local row.
- Remote changes arrive via `CKDatabaseSubscription` silent pushes
  (plus foreground + 3-minute polling as fallback).
- Sharing uses a CloudKit shared zone (`CKShare`): the owner writes to the
  private database, partners to the shared database. Share acceptance is
  handled in `SceneDelegate.userDidAcceptCloudKitShareWith`.
