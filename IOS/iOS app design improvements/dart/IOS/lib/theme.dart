import 'package:flutter/material.dart';

// ── Modernist palette ─────────────────────────────────────
// Flat, architectural, one accent. No gradients, no radii, 2px rules.

const kInk       = Color(0xFF201E1D); // near-black — text, rules, chrome
const kInk2      = Color(0xFF444141);
const kInk3      = Color(0xFF605D5D); // secondary text
const kInk4      = Color(0xFF7D7979); // labels
const kInk5      = Color(0xFF9B9797); // disabled
const kPaper     = Color(0xFFF3F2F2); // page
const kPaper2    = Color(0xFFEAE9E9); // recessed surface
const kAccent    = Color(0xFFEC3013); // the single accent
const kAccentDk  = Color(0xFFAE1800); // accent text on light bg (AA)
const kAccentLt  = Color(0xFFFFC4B8); // accent tint — half-strength days

// Dark mode. The old theme pinned #2e7d32 on #121212, which fails contrast
// for text. These are tuned so accent-on-surface passes AA at body size.
const kInkD      = Color(0xFF191817); // page
const kInkD2     = Color(0xFF221F1E); // surface
const kRuleD     = Color(0xFF4A4644);
const kPaperD    = Color(0xFFF0EEED); // text on dark
const kPaperD2   = Color(0xFFA9A4A1);
const kAccentD   = Color(0xFFFF6B4F); // lifted accent for dark surfaces

const kFont = 'Archivo';

// ── Type scale ────────────────────────────────────────────
// Archivo at heavy weights with tight tracking is the whole identity.
// Everything below 24px is uppercase + letterspaced, never light grey mush.

abstract class AppType {
  /// Large iOS-style screen title.
  static const title = TextStyle(
      fontFamily: kFont,
      fontSize: 34,
      height: 1.0,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.7);

  /// Big number — dashboard hero figures.
  static const figure = TextStyle(
      fontFamily: kFont,
      fontSize: 62,
      height: 0.85,
      fontWeight: FontWeight.w800,
      letterSpacing: -2.4);

  /// Card / row heading.
  static const heading = TextStyle(
      fontFamily: kFont,
      fontSize: 17,
      height: 1.1,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2);

  static const body = TextStyle(
      fontFamily: kFont, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500);

  static const bodySm = TextStyle(
      fontFamily: kFont, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500);

  /// Uppercase section label — replaces the old 11px grey caps.
  static const label = TextStyle(
      fontFamily: kFont,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4);

  /// Text inside a block button.
  static const button = TextStyle(
      fontFamily: kFont,
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6);
}

// ── ThemeData ─────────────────────────────────────────────

ThemeData _base(Brightness b) {
  final dark = b == Brightness.dark;
  final bg = dark ? kInkD : kPaper;
  final surface = dark ? kInkD2 : Colors.white;
  final onSurface = dark ? kPaperD : kInk;
  final accent = dark ? kAccentD : kAccent;

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: kFont,
    scaffoldBackgroundColor: bg,
    cardColor: surface,
    dividerColor: dark ? kRuleD : kInk,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: b,
    ).copyWith(
      primary: accent,
      secondary: onSurface,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: dark ? kPaperD2 : kInk3,
    ),
    // Modernist has no rounded corners anywhere. Zeroing the shape defaults
    // once here means individual screens don't have to fight Material 3.
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppType.heading.copyWith(color: onSurface),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: bg,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: bg,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: onSurface, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: onSurface,
      contentTextStyle: AppType.body.copyWith(color: bg),
      behavior: SnackBarBehavior.fixed,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : null),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: AppType.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: dark ? kAccentD : kAccentDk,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: AppType.body.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? kInkD2 : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: onSurface, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: onSurface, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: accent, width: 2),
      ),
      labelStyle: AppType.bodySm.copyWith(color: dark ? kPaperD2 : kInk3),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  );
}

final kLightTheme = _base(Brightness.light);
final kDarkTheme = _base(Brightness.dark);

// ── Per-build colour palette ──────────────────────────────
// Field names are unchanged from the old green theme so the existing
// screens keep compiling — only the values moved. `green` is now the
// Modernist accent; rename it across the codebase when convenient.

class AppColors {
  final Color bg;
  final Color card;
  final Color border;
  final Color txt;
  final Color txt2;

  /// The single accent. Named `green` for source compatibility.
  final Color green;

  /// Accent text on a light background — darkened to hold AA at body size.
  final Color accentTxt;

  /// Half-strength accent — one-parent days, secondary bars.
  final Color accentLt;

  /// Tinted surface for selected / highlighted rows.
  final Color greenTint;

  /// Tinted surface for warning rows (missed activities, …).
  final Color redTint;

  /// Hairline inside a bordered block (1px, 40% ink).
  final Color hairline;

  final bool isDark;

  AppColors.of(BuildContext ctx) : this._(Theme.of(ctx));

  AppColors._(ThemeData t)
      : isDark = t.brightness == Brightness.dark,
        bg = t.scaffoldBackgroundColor,
        card = t.cardColor,
        border = t.brightness == Brightness.dark ? kRuleD : kInk,
        txt = t.colorScheme.onSurface,
        txt2 = t.colorScheme.onSurfaceVariant,
        green = t.colorScheme.primary,
        accentTxt = t.brightness == Brightness.dark ? kAccentD : kAccentDk,
        accentLt =
            t.brightness == Brightness.dark ? const Color(0xFF7A2E1F) : kAccentLt,
        greenTint = t.brightness == Brightness.dark
            ? const Color(0xFF2E1A15)
            : const Color(0xFFFDE7E2),
        redTint = t.brightness == Brightness.dark
            ? const Color(0xFF2E1C1C)
            : const Color(0xFFFFF5F5),
        hairline = t.brightness == Brightness.dark
            ? kRuleD
            : const Color(0x66201E1D);
}
