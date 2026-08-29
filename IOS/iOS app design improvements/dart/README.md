# Playground Tracker — iOS restructure (drop-in Dart)

Written against `anelcelik/playground@92712a91`, `IOS/` module. Copy the
files over the same paths in `IOS/lib/`, then run the two steps below.

## Files

| Path | New / replaces |
| --- | --- |
| `lib/theme.dart` | **replaces** — Modernist tokens, type scale, zeroed Material 3 shapes, fixed dark mode |
| `lib/main.dart` | **replaces** — paywall removed from `_AppRouter` |
| `lib/screens/home_screen.dart` | **replaces** — bottom tab bar, 4 destinations |
| `lib/widgets/modernist.dart` | new — `Rule`, `Hairline`, `SectionLabel`, `BlockButton`, `SquareChip`, `Block` |
| `lib/screens/today_screen.dart` | new — the fast-path log screen |
| `lib/screens/quick_visit_sheet.dart` | new — the two-tap detail sheet |
| `lib/screens/settings_screen.dart` | new — the fourth tab |

Nothing in `db/`, `models/`, `services/`, `sync/`, `notifications/` or
`settings/` was touched. No schema migration.

## Two steps to compile

**1. Add the font.** Put Archivo TTFs in `IOS/assets/fonts/` and add to
`pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Archivo
      fonts:
        - asset: assets/fonts/Archivo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Archivo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Archivo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Archivo-Bold.ttf
          weight: 700
        - asset: assets/fonts/Archivo-ExtraBold.ttf
          weight: 800
```

Archivo is SIL Open Font License — free to ship. Get it from Google Fonts.
Without this step everything still builds, it just falls back to the system
font and loses the identity.

**2. Delete the paywall.** `lib/screens/paywall_screen.dart` and
`lib/purchase/purchase_service.dart` are now unreferenced. Remove both,
plus `in_app_purchase` from `pubspec.yaml`. Also drop the `_metaKey`
row it wrote (`purchased`) if you care about a clean meta table — harmless
either way.

## Deliberate compromises

**`AppColors.green` is now red.** The field names in `AppColors` are
unchanged so `dashboard_screen.dart`, `entry_screen.dart`,
`recap_screen.dart` and the other ten screens keep compiling untouched.
`green` holds the Modernist accent, and `greenTint` is now a warm tint.
Rename across the codebase when you have an afternoon; nothing breaks if
you never do.

**`entry_screen.dart` is still there and still Material.** `TodayScreen`
replaces it in the tab bar but the file is untouched, so you can diff
behaviour or fall back. Delete it once you trust the new path.

**Not restyled yet:** `dashboard_screen.dart`, `recap_screen.dart`,
`manage_recurring_screen.dart`, `recurring_activity_form.dart`,
`setup_screen.dart`, `edit_entry_screen.dart`, `invite_family_screen.dart`,
`notifications_screen.dart`, `display_settings_screen.dart`. They inherit
the new `ThemeData` — so no green, no rounded corners, correct fonts — but
their internal layouts are still the old card-and-uppercase-label pattern.
The designs for History, Recap and Plans show where they should land.

**One thing to verify:** `getMostRecentVisitEntries()` is assumed to
return `List<Entry>` ordered most-recent-first. `TodayScreen._repeatLast`
reads `.first`. If the ordering is the other way round, flip it to
`.last`.
