import 'package:flutter/material.dart';

// ── Modernist tokens ──────────────────────────────────────
// Flat, architectural, zero radius, 2px rules, one red accent.
//
// NOTE ON NAMES: the old green constants keep their names on purpose so the
// screens that were NOT rewritten (entry_screen, edit_entry_screen,
// setup_screen, dashboard_screen, recap_screen, notifications_screen, …) still
// compile and pick up the new palette for free. Only their values changed.

const kInk      = Color(0xFF201E1D); // --color-text
const kGround   = Color(0xFFF3F2F2); // --color-bg
const kSurface  = Color(0xFFEAE9E9); // --color-surface
const kAccent   = Color(0xFFEC3013); // --color-accent
const kAccent300 = Color(0xFFFFC4B8);
const kAccent600 = Color(0xFFDD2B0F); // pressed
const kAccent700 = Color(0xFFAE1800); // accent text at body size
const kN300     = Color(0xFFD7D3D3);
const kN500     = Color(0xFF9B9797);
const kN600     = Color(0xFF7D7979);
const kN700     = Color(0xFF605D5D);
const kN800     = Color(0xFF444141);

// Legacy aliases — same names, Modernist values.
const kGreen   = kAccent;
const kGreenLt = Color(0xFFFF563C);
const kGreenDk = kAccent700;
const kAmber   = kInk;
const kBlue    = kN700;

const kFont = 'Archivo';

// Strong 2px rule — use everywhere a section ends.
const kRule = BorderSide(color: kInk, width: 2);
const kHair = BorderSide(color: Color(0x66201E1D), width: 1);

TextTheme _text(Color ink, Color ink2) => TextTheme(
      displayLarge: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w900, fontSize: 56, letterSpacing: -2, color: ink),
      headlineLarge: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w800, fontSize: 34, letterSpacing: -0.7, color: ink),
      headlineSmall: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.2, color: ink),
      titleMedium: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.2, color: ink),
      bodyLarge: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w500, fontSize: 15, color: ink),
      bodyMedium: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w400, fontSize: 13.5, height: 1.5, color: ink2),
      labelLarge: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.6, color: ink),
      // The uppercase 10px section label used all over the design.
      labelSmall: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1.4, color: ink2),
    );

final kLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: kFont,
  scaffoldBackgroundColor: kGround,
  cardColor: kGround,
  dividerColor: kInk,
  splashFactory: NoSplash.splashFactory,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    onPrimary: Colors.white,
    secondary: kInk,
    onSecondary: Colors.white,
    surface: kGround,
    onSurface: kInk,
    onSurfaceVariant: kN700,
    outline: kN300,
  ),
  textTheme: _text(kInk, kN800),
  appBarTheme: const AppBarTheme(
    backgroundColor: kGround,
    foregroundColor: kInk,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
        fontFamily: kFont, fontWeight: FontWeight.w800, fontSize: 20, color: kInk),
  ),
  // Zero radius everywhere.
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      textStyle: const TextStyle(
          fontFamily: kFont, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.6),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kAccent700,
      shape: const RoundedRectangleBorder(),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: kGround,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: kN300, width: 2)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: kN300, width: 2)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: kAccent, width: 2)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kAccent : kN500),
    trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kAccent300 : kSurface),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: kInk,
    contentTextStyle: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w600, color: Colors.white),
    shape: RoundedRectangleBorder(),
    behavior: SnackBarBehavior.floating,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: kGround,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: kGround,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kAccent,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(),
  ),
);

// Dark: ink ground, red stays the accent, no tinted greens.
const _dGround  = Color(0xFF1A1918);
const _dSurface = Color(0xFF262423);
const _dInk     = Color(0xFFF3F2F2);

final kDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: kFont,
  scaffoldBackgroundColor: _dGround,
  cardColor: _dGround,
  dividerColor: _dInk,
  splashFactory: NoSplash.splashFactory,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF563C), // accent-400 — accent one step lighter on dark
    onPrimary: Color(0xFF1A1918),
    secondary: _dInk,
    surface: _dGround,
    onSurface: _dInk,
    onSurfaceVariant: Color(0xFFBAB6B6),
    outline: Color(0xFF444141),
  ),
  textTheme: _text(_dInk, const Color(0xFFBAB6B6)),
  appBarTheme: const AppBarTheme(
    backgroundColor: _dGround,
    foregroundColor: _dInk,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF563C),
      foregroundColor: const Color(0xFF1A1918),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: _dSurface,
    border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF444141), width: 2)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF444141), width: 2)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFFF563C), width: 2)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: _dGround,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: _dGround,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: _dInk,
    contentTextStyle: TextStyle(fontFamily: kFont, fontWeight: FontWeight.w600, color: Color(0xFF1A1918)),
    shape: RoundedRectangleBorder(),
    behavior: SnackBarBehavior.floating,
  ),
);

// ── Per-build palette ─────────────────────────────────────
// Same class, same field names as before — existing screens keep working.

class AppColors {
  final Color bg;
  final Color card;
  final Color border;
  final Color txt;
  final Color txt2;
  final Color green; // now the red accent; name kept for compatibility
  final Color greenTint;
  final Color redTint;
  final bool dark;

  AppColors.of(BuildContext ctx)
      : dark   = Theme.of(ctx).brightness == Brightness.dark,
        bg     = Theme.of(ctx).scaffoldBackgroundColor,
        card   = Theme.of(ctx).scaffoldBackgroundColor,
        border = Theme.of(ctx).brightness == Brightness.dark
                   ? const Color(0xFF444141)
                   : kInk,
        txt    = Theme.of(ctx).colorScheme.onSurface,
        txt2   = Theme.of(ctx).colorScheme.onSurfaceVariant,
        green  = Theme.of(ctx).colorScheme.primary,
        greenTint = Theme.of(ctx).brightness == Brightness.dark
                   ? const Color(0xFF2E1C18)
                   : kAccent300,
        redTint = Theme.of(ctx).brightness == Brightness.dark
                   ? const Color(0xFF2E1C18)
                   : const Color(0xFFFFE0D9);
}

// ── Shared flat primitives ────────────────────────────────

/// 10px uppercase tracked label that opens every section.
class ModLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const ModLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final style = TextStyle(
        fontFamily: kFont,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: c.txt2);
    if (trailing == null) return Text(text.toUpperCase(), style: style);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(text.toUpperCase(), style: style), trailing!],
    );
  }
}

/// The strong 2px horizontal rule.
class ModRule extends StatelessWidget {
  final double top;
  final double bottom;
  const ModRule({super.key, this.top = 0, this.bottom = 0});

  @override
  Widget build(BuildContext context) => Container(
        height: 2,
        margin: EdgeInsets.only(top: top, bottom: bottom),
        color: AppColors.of(context).border,
      );
}

/// A boxed cell: 2px border, no radius, no shadow.
class ModBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? fill;
  final bool muted;
  const ModBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    this.onTap,
    this.fill,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(
              color: muted ? c.border.withValues(alpha: 0.3) : c.border, width: 2),
        ),
        child: child,
      ),
    );
  }
}

/// Selectable chip — filled ink when on, 2px outline when off. Zero radius.
class ModChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? selectedFill;
  final IconData? icon;
  final bool small;
  const ModChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.selectedFill,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fill = selectedFill ?? (c.dark ? c.txt : kInk);
    final fg = selected ? (c.dark ? c.bg : Colors.white) : c.txt;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: small ? 11 : 16, vertical: small ? 7 : 10),
        decoration: BoxDecoration(
          color: selected ? fill : Colors.transparent,
          border: Border.all(
              color: selected ? fill : c.border.withValues(alpha: 0.4), width: 2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 12 : 14, color: fg),
            const SizedBox(width: 7),
          ],
          Text(label,
              style: TextStyle(
                  fontFamily: kFont,
                  fontSize: small ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: small ? 0.5 : 0,
                  color: fg)),
        ]),
      ),
    );
  }
}
