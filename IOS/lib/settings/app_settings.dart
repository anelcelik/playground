import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/goal.dart';
import '../theme.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._();
  AppSettings._();

  /// The app's languages, as offered in onboarding and Settings.
  static const languages = ['en', 'es', 'de', 'bs', 'cs'];

  /// Each language's name in itself.
  static const languageNames = {
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
    'bs': 'Bosanski',
    'cs': 'Čeština',
  };

  String? _language; // null = follow the phone
  bool _use24h = false;
  bool _euDate = true; // true = European d MMM yyyy | false = US MMM d, yyyy
  AppPalette _palette = AppPalette.modernistLight;
  // "My colors": white background, black text, blue accent until edited.
  Color _customBg = Colors.white;
  Color _customTxt = Colors.black;
  Color _customAccent = const Color(0xFF1565C0);
  // Visit sheet: exact start / end times instead of a preset length.
  bool _exactTimes = false;
  OutdoorGoal? _goal;

  /// The chosen language, or null while the app follows the phone.
  String? get language => _language;

  /// The language in use: the chosen one, else the phone's first supported
  /// language, else English.
  Locale get locale => Locale(_language ?? phoneLanguage);

  bool get isEnglish => locale.languageCode == 'en';

  /// The phone's first language the app speaks. Croatian and Serbian phones
  /// get Bosnian, which they read without effort.
  static String get phoneLanguage {
    for (final l in PlatformDispatcher.instance.locales) {
      final code = l.languageCode;
      if (languages.contains(code)) return code;
      if (code == 'hr' || code == 'sr') return 'bs';
    }
    return 'en';
  }

  bool get use24h => _use24h;
  bool get euDate => _euDate;
  AppPalette get palette => _palette;
  Color get customBg => _customBg;
  Color get customTxt => _customTxt;
  Color get customAccent => _customAccent;
  bool get exactTimes => _exactTimes;

  /// The family's outdoor-time goal, or null when none is set.
  OutdoorGoal? get goal => _goal;

  /// The colours in use: the chosen palette's, or the user's own.
  AppColors get colors => _palette.fixed ?? customColors;
  AppColors get customColors => AppColors.custom(
      bg: _customBg, txt: _customTxt, accent: _customAccent);

  Future<void> load() async {
    final lang = await DatabaseHelper.instance.getMeta('setting_language');
    _language = languages.contains(lang) ? lang : null;
    Intl.defaultLocale = locale.languageCode;
    _use24h   = await DatabaseHelper.instance.getMeta('setting_24h') == '1';
    final eu  = await DatabaseHelper.instance.getMeta('setting_eu_date');
    _euDate   = eu == null || eu == '1'; // default to European
    // Until 11 Oct 2026 a palette (modernist / swing) came with a separate
    // System / Light / Dark setting; both now map onto one theme. Nothing
    // chosen yet follows the phone's current look.
    final mode = await DatabaseHelper.instance.getMeta('setting_theme');
    final dark = switch (mode) {
      'dark' => true,
      'light' => false,
      _ => PlatformDispatcher.instance.platformBrightness == Brightness.dark,
    };
    final pal = await DatabaseHelper.instance.getMeta('setting_palette');
    _palette = switch (pal) {
      'swing' => dark ? AppPalette.swingDark : AppPalette.swingLight,
      _ => AppPalette.values.firstWhere((p) => p.name == pal,
          orElse: () =>
              dark ? AppPalette.modernistDark : AppPalette.modernistLight),
    };
    Color? color(String? v) => v == null ? null : Color(int.parse(v));
    _customBg = color(await DatabaseHelper.instance.getMeta('custom_bg')) ??
        Colors.white;
    _customTxt = color(await DatabaseHelper.instance.getMeta('custom_txt')) ??
        Colors.black;
    _customAccent =
        color(await DatabaseHelper.instance.getMeta('custom_accent')) ??
            const Color(0xFF1565C0);
    _exactTimes =
        await DatabaseHelper.instance.getMeta('setting_exact_times') == '1';
    _goal = OutdoorGoal.parse(
        await DatabaseHelper.instance.getMeta('goal_period'),
        await DatabaseHelper.instance.getMeta('goal_minutes'));
  }

  /// [code] from [languages], or null to follow the phone. Notifications are
  /// rescheduled so their text switches too.
  Future<void> setLanguage(String? code) async {
    _language = code;
    Intl.defaultLocale = locale.languageCode;
    await DatabaseHelper.instance.setMeta('setting_language', code ?? 'phone');
    notifyListeners();
    await onLanguageChanged?.call();
  }

  /// Set by main(): reschedules notifications in the new language.
  Future<void> Function()? onLanguageChanged;

  /// Re-reads every setting (after Delete all data) and redraws the app.
  Future<void> reload() async {
    await load();
    notifyListeners();
  }

  Future<void> setUse24h(bool v) async {
    _use24h = v;
    await DatabaseHelper.instance.setMeta('setting_24h', v ? '1' : '0');
    notifyListeners();
  }

  Future<void> setEuDate(bool v) async {
    _euDate = v;
    await DatabaseHelper.instance.setMeta('setting_eu_date', v ? '1' : '0');
    notifyListeners();
  }

  /// "My colors": stores any of the three and switches to the custom theme.
  Future<void> setCustomColors({Color? bg, Color? txt, Color? accent}) async {
    final db = DatabaseHelper.instance;
    if (bg != null) {
      _customBg = bg;
      await db.setMeta('custom_bg', '${bg.toARGB32()}');
    }
    if (txt != null) {
      _customTxt = txt;
      await db.setMeta('custom_txt', '${txt.toARGB32()}');
    }
    if (accent != null) {
      _customAccent = accent;
      await db.setMeta('custom_accent', '${accent.toARGB32()}');
    }
    await setPalette(AppPalette.custom);
  }

  /// Remembered so the visit sheet opens the way it was last used.
  Future<void> setExactTimes(bool v) async {
    _exactTimes = v;
    // No notifyListeners: nothing on screen depends on it.
    await DatabaseHelper.instance.setMeta('setting_exact_times', v ? '1' : '0');
  }

  /// [g], or null to turn the goal off.
  Future<void> setGoal(OutdoorGoal? g) async {
    _goal = g;
    await DatabaseHelper.instance.setMeta('goal_period', g?.period.name ?? '');
    await DatabaseHelper.instance.setMeta('goal_minutes', '${g?.minutes ?? 0}');
    notifyListeners();
  }

  Future<void> setPalette(AppPalette p) async {
    _palette = p;
    await DatabaseHelper.instance.setMeta('setting_palette', p.name);
    notifyListeners();
  }

  // ── Date helpers ──────────────────────────────────────────

  // English keeps the EU / US choice; every other language uses its own
  // conventions (de "12. Okt. 2026", cs "12. 10. 2026").

  /// "3 Jun 2025"  /  "Jun 3, 2025"
  String fmtDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    if (!isEnglish) return DateFormat.yMMMd().format(d);
    return _euDate
        ? DateFormat('d MMM yyyy').format(d)
        : DateFormat('MMM d, yyyy').format(d);
  }

  /// "Mon, 3 Jun 2025"  /  "Mon, Jun 3, 2025"
  String fmtDateFull(String dateStr) {
    final d = DateTime.parse(dateStr);
    if (!isEnglish) return DateFormat.yMMMEd().format(d);
    return _euDate
        ? DateFormat('EEE, d MMM yyyy').format(d)
        : DateFormat('EEE, MMM d, yyyy').format(d);
  }

  /// "3 Jun"  /  "Jun 3"
  String fmtDateShort(String dateStr) {
    final d = DateTime.parse(dateStr);
    if (!isEnglish) return DateFormat.MMMd().format(d);
    return _euDate
        ? DateFormat('d MMM').format(d)
        : DateFormat('MMM d').format(d);
  }

  /// "June 2025"  —  month label, same either way
  String fmtMonth(String yearMonth) {
    final p = yearMonth.split('-').map(int.parse).toList();
    final d = DateTime(p[0], p[1]);
    return isEnglish
        ? DateFormat('MMMM yyyy').format(d)
        : DateFormat.yMMMM().format(d);
  }

  /// "3 – 9 Jun 2025"  /  "Jun 3 – 9, 2025"
  String fmtWeekRange(String start, String end) {
    final s = DateTime.parse(start);
    final e = DateTime.parse(end);
    if (!isEnglish) {
      return '${DateFormat.MMMd().format(s)} – ${DateFormat.yMMMd().format(e)}';
    }
    if (_euDate) {
      if (s.month == e.month) {
        return '${s.day} – ${e.day} ${DateFormat('MMM yyyy').format(s)}';
      }
      return '${DateFormat('d MMM').format(s)} – ${DateFormat('d MMM yyyy').format(e)}';
    } else {
      if (s.month == e.month) {
        return '${DateFormat('MMM').format(s)} ${s.day} – ${e.day}, ${s.year}';
      }
      return '${DateFormat('MMM d').format(s)} – ${DateFormat('MMM d, yyyy').format(e)}';
    }
  }

  // ── Time helpers ──────────────────────────────────────────

  /// 14:30  /  2:30 PM
  String fmtHM(int hour, int minute) {
    if (_use24h) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m ${hour < 12 ? 'AM' : 'PM'}';
  }

  /// Format from Flutter's TimeOfDay
  String fmtTimeOfDay(TimeOfDay t) => fmtHM(t.hour, t.minute);

  /// Stored "15:10" → 15:10 / 3:10 PM; the stored text if malformed.
  String fmtClock(String hm) {
    final p = hm.split(':').map(int.tryParse).toList();
    if (p.length != 2 || p.contains(null)) return hm;
    return fmtHM(p[0]!, p[1]!);
  }

  /// "15:10–16:40"  /  "3:10 PM–4:40 PM"
  String fmtClockRange(String start, String end) =>
      '${fmtClock(start)}–${fmtClock(end)}';
}
