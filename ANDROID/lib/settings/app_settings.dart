import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._();
  AppSettings._();

  bool _use24h = false;
  bool _euDate = true; // true = European d MMM yyyy | false = US MMM d, yyyy

  bool get use24h => _use24h;
  bool get euDate => _euDate;

  Future<void> load() async {
    _use24h   = await DatabaseHelper.instance.getMeta('setting_24h') == '1';
    final eu  = await DatabaseHelper.instance.getMeta('setting_eu_date');
    _euDate   = eu == null || eu == '1'; // default to European
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

  // ── Date helpers ──────────────────────────────────────────

  /// "3 Jun 2025"  /  "Jun 3, 2025"
  String fmtDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    return _euDate
        ? DateFormat('d MMM yyyy').format(d)
        : DateFormat('MMM d, yyyy').format(d);
  }

  /// "Mon, 3 Jun 2025"  /  "Mon, Jun 3, 2025"
  String fmtDateFull(String dateStr) {
    final d = DateTime.parse(dateStr);
    return _euDate
        ? DateFormat('EEE, d MMM yyyy').format(d)
        : DateFormat('EEE, MMM d, yyyy').format(d);
  }

  /// "3 Jun"  /  "Jun 3"
  String fmtDateShort(String dateStr) {
    final d = DateTime.parse(dateStr);
    return _euDate
        ? DateFormat('d MMM').format(d)
        : DateFormat('MMM d').format(d);
  }

  /// "June 2025"  —  month label, same either way
  String fmtMonth(String yearMonth) {
    final p = yearMonth.split('-').map(int.parse).toList();
    return DateFormat('MMMM yyyy').format(DateTime(p[0], p[1]));
  }

  /// "3 – 9 Jun 2025"  /  "Jun 3 – 9, 2025"
  String fmtWeekRange(String start, String end) {
    final s = DateTime.parse(start);
    final e = DateTime.parse(end);
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
}
