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

// Swing — the doodle swing app icon: sunny ground, deep green frame,
// orange seat. Light mode is green ink on yellow paper; dark mode inverts it.
const kSwingYellow = Color(0xFFFFB31F);
const kSwingGreen  = Color(0xFF12443A);
const kSwingOrange = Color(0xFFF0512E);

const kFont = 'Archivo';

// Legacy names, Modernist values. The screens that were not rewritten
// (entry_screen, edit_entry_screen, setup_screen, dashboard_screen,
// notifications_screen, recurring_activity_form, manage_recurring_screen,
// invite_family_screen) still reference these as const, so they keep the
// names and pick up the new palette for free.
const kGreen   = kAccent;
const kGreenLt = Color(0xFFFF563C);
const kGreenDk = kAccentDk;
const kAmber   = kInk;
const kBlue    = kInk3;

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

/// The app theme for one colour palette at one brightness. Everything a
/// screen reads goes through [AppColors], which rides along as an extension.
ThemeData buildTheme(AppPalette palette, Brightness b) {
  final c = palette.colors(b);
  final bg = c.bg;
  final surface = c.card;
  final onSurface = c.txt;
  final accent = c.green;

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: kFont,
    scaffoldBackgroundColor: bg,
    cardColor: surface,
    dividerColor: c.border,
    extensions: [c],
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: b,
    ).copyWith(
      primary: accent,
      onPrimary: c.onAccent,
      secondary: onSurface,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: c.txt2,
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
      actionTextColor: bg,
      behavior: SnackBarBehavior.fixed,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onAccent : null),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : null),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: c.onAccent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: AppType.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.accentTxt,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: AppType.body.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
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
      labelStyle: AppType.bodySm.copyWith(color: c.txt2),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: c.onAccent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  );
}

final kLightTheme = buildTheme(AppPalette.modernist, Brightness.light);
final kDarkTheme = buildTheme(AppPalette.modernist, Brightness.dark);

// ── Colour palettes ───────────────────────────────────────

/// The colour themes offered in Display settings. Light / dark stays the
/// separate Appearance choice; each palette has a set for both.
enum AppPalette {
  modernist('Modernist', 'Red and black on paper — the original look',
      [kPaper, kInk, kAccent]),
  swing('Swing', 'Sunny yellow, deep green and orange, from the app icon',
      [kSwingYellow, kSwingGreen, kSwingOrange]);

  const AppPalette(this.label, this.description, this.swatches);
  final String label;
  final String description;
  final List<Color> swatches;

  AppColors colors(Brightness b) => switch (this) {
        AppPalette.modernist => b == Brightness.dark
            ? AppColors.modernistDark
            : AppColors.modernistLight,
        AppPalette.swing =>
          b == Brightness.dark ? AppColors.swingDark : AppColors.swingLight,
      };
}


// ── Per-build colour palette ──────────────────────────────
// Field names are unchanged from the old green theme so the existing
// screens keep compiling — only the values moved. `green` is the palette's
// accent; rename it across the codebase when convenient.

class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color card;

  /// Recessed surface — logged blocks, empty bar tracks.
  final Color recessed;
  final Color border;
  final Color txt;
  final Color txt2;

  /// The single accent. Named `green` for source compatibility.
  final Color green;

  /// Text and icons drawn on top of [green].
  final Color onAccent;

  /// Accent text on the page background — held at AA for body size.
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

  const AppColors({
    required this.bg,
    required this.card,
    required this.recessed,
    required this.border,
    required this.txt,
    required this.txt2,
    required this.green,
    required this.onAccent,
    required this.accentTxt,
    required this.accentLt,
    required this.greenTint,
    required this.redTint,
    required this.hairline,
    required this.isDark,
  });

  factory AppColors.of(BuildContext ctx) =>
      Theme.of(ctx).extension<AppColors>() ?? modernistLight;

  static const modernistLight = AppColors(
    bg: kPaper,
    card: Colors.white,
    recessed: kPaper2,
    border: kInk,
    txt: kInk,
    txt2: kInk3,
    green: kAccent,
    onAccent: Colors.white,
    accentTxt: kAccentDk,
    accentLt: kAccentLt,
    greenTint: Color(0xFFFDE7E2),
    redTint: Color(0xFFFFF5F5),
    hairline: Color(0x66201E1D),
    isDark: false,
  );

  static const modernistDark = AppColors(
    bg: kInkD,
    card: kInkD2,
    recessed: kInkD2,
    border: kRuleD,
    txt: kPaperD,
    txt2: kPaperD2,
    green: kAccentD,
    onAccent: Colors.white,
    accentTxt: kAccentD,
    accentLt: Color(0xFF7A2E1F),
    greenTint: Color(0xFF2E1A15),
    redTint: Color(0xFF2E1C1C),
    hairline: kRuleD,
    isDark: true,
  );

  // Contrast (WCAG): ink on page 10.0, secondary text 5.4, accent text 4.7,
  // white on the green accent 11.0.
  static const swingLight = AppColors(
    bg: Color(0xFFFFF4D6),
    card: Colors.white,
    recessed: Color(0xFFFCE9B8),
    border: kSwingGreen,
    txt: kSwingGreen,
    txt2: Color(0xFF4A6A61),
    green: kSwingGreen,
    onAccent: Colors.white,
    accentTxt: Color(0xFFC2401C),
    accentLt: kSwingOrange,
    greenTint: Color(0xFFFFE3A1),
    redTint: Color(0xFFFFE9E2),
    hairline: Color(0x6612443A),
    isDark: false,
  );

  // Contrast: text on page 13.8, secondary 8.7, yellow accent text 8.4,
  // green on the yellow accent 6.1.
  static const swingDark = AppColors(
    bg: Color(0xFF0E2B24),
    card: Color(0xFF153A31),
    recessed: Color(0xFF153A31),
    border: Color(0xFF2F5D51),
    txt: Color(0xFFFFF4D6),
    txt2: Color(0xFFB4C9C1),
    green: kSwingYellow,
    onAccent: kSwingGreen,
    accentTxt: kSwingYellow,
    accentLt: kSwingOrange,
    greenTint: Color(0xFF3A3517),
    redTint: Color(0xFF3A1F18),
    hairline: Color(0xFF2F5D51),
    isDark: true,
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      card: l(card, other.card),
      recessed: l(recessed, other.recessed),
      border: l(border, other.border),
      txt: l(txt, other.txt),
      txt2: l(txt2, other.txt2),
      green: l(green, other.green),
      onAccent: l(onAccent, other.onAccent),
      accentTxt: l(accentTxt, other.accentTxt),
      accentLt: l(accentLt, other.accentLt),
      greenTint: l(greenTint, other.greenTint),
      redTint: l(redTint, other.redTint),
      hairline: l(hairline, other.hairline),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}
