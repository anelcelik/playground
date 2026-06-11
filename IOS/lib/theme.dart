import 'package:flutter/material.dart';

const kGreen   = Color(0xFF2e7d32);
const kGreenLt = Color(0xFF4caf50);
const kGreenDk = Color(0xFF1b5e20);
const kAmber   = Color(0xFFf57f17);
const kBlue    = Color(0xFF1565c0);

// ── Light & dark ThemeData ────────────────────────────────

final kLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kGreen,
    brightness: Brightness.light,
  ).copyWith(primary: kGreen, secondary: kGreenLt),
  scaffoldBackgroundColor: const Color(0xFFF4F6F4),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFDDE2DD),
  appBarTheme: const AppBarTheme(
    backgroundColor: kGreen,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: Colors.black26,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kGreen : null),
    trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kGreenLt.withAlpha(120) : null),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kGreen,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kGreen,
      foregroundColor: Colors.white,
    ),
  ),
);

final kDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kGreen,
    brightness: Brightness.dark,
  ).copyWith(primary: kGreenLt, secondary: kGreenLt),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: const Color(0xFF3A3A3A),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1B3A1E),
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kGreenLt : null),
    trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kGreenLt.withAlpha(120) : null),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kGreenLt,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kGreenLt,
      foregroundColor: Colors.white,
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF2A2A2A),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Color(0xFF1E1E1E),
  ),
);

// ── Per-build colour palette ──────────────────────────────
// Instantiate once at the top of build(), pass to helpers.

class AppColors {
  final Color bg;
  final Color card;
  final Color border;
  final Color txt;
  final Color txt2;
  final Color green;

  /// Soft green surface for selected / highlighted rows and banners.
  final Color greenTint;

  /// Soft red surface for warning rows (missed activities, …).
  final Color redTint;

  AppColors.of(BuildContext ctx)
      : bg     = Theme.of(ctx).scaffoldBackgroundColor,
        card   = Theme.of(ctx).cardColor,
        border = Theme.of(ctx).brightness == Brightness.dark
                   ? const Color(0xFF3A3A3A)
                   : const Color(0xFFDDE2DD),
        txt    = Theme.of(ctx).colorScheme.onSurface,
        txt2   = Theme.of(ctx).colorScheme.onSurfaceVariant,
        green  = Theme.of(ctx).colorScheme.primary,
        greenTint = Theme.of(ctx).brightness == Brightness.dark
                   ? const Color(0xFF1C2E1E)
                   : const Color(0xFFEDF7ED),
        redTint  = Theme.of(ctx).brightness == Brightness.dark
                   ? const Color(0xFF2E1C1C)
                   : const Color(0xFFFFF5F5);
}
