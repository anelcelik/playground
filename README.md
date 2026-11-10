# Playground Tracker

An iPhone app for parents: log who took the kids out, for how long and what
they did, mark the days nobody went and why, keep plans that repeat, and
share the log with a partner through iCloud.

Everything is stored on the phone. With iCloud signed in, the log also lives
in the family's own iCloud; nothing goes to a server of ours.

## What's here

| Path | What it is |
|------|------------|
| `IOS/` | The app (Flutter, with a committed Xcode project). See `IOS/README.md`. |
| `webpagepreparation/` | Texts for the App Store listing, the privacy policy and the support page, plus the store screenshots. |
| `.github/workflows/` | `ios.yml` builds an unsigned IPA; `ios-testflight.yml` builds, signs and uploads for a `v*` tag. |

## Build and run

Development happens on Linux; the app runs there as a desktop window with
iCloud sync switched off:

```bash
cd IOS
flutter pub get
flutter run -d linux
flutter analyze && flutter test
```

iPhone builds come from GitHub Actions, so no Mac is needed. `IOS/README.md`
has the details, including how sync and sharing work.

## Tech

Flutter / Dart, SQLite (`sqflite`), CloudKit through a small Swift plugin,
`flutter_local_notifications` for reminders.
