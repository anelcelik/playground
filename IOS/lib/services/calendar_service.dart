import 'package:flutter/services.dart';

import '../models/recurring_activity.dart';

/// "Add to Calendar" for a plan. iOS only: opens the system New Event sheet
/// (CalendarBridge in AppDelegate.swift) prefilled with the plan's title,
/// first day, time and weekly repeat. Apps cannot send calendar invitations
/// themselves — invitees are added in that sheet, and iCloud sends them.
class CalendarService {
  static const _channel = MethodChannel('com.playground.tracker/calendar');

  /// 'saved' | 'cancelled' | 'denied' | 'unavailable' (not on iPhone) |
  /// 'none' (the plan has no day left to add).
  static Future<String> addPlan(RecurringActivity a) async {
    final start = firstStart(a, DateTime.now());
    if (start == null) return 'none';
    try {
      final result = await _channel.invokeMethod<String>('addEvent', {
        'title': a.title,
        if (a.kidNames.isNotEmpty) 'notes': 'With ${a.kidNames.join(', ')}',
        'startMs': start.millisecondsSinceEpoch,
        'durationMin': 60,
        if (!a.isOneTime) 'weekdays': a.repeatDays, // 0 = Mon … 6 = Sun
        if (!a.isOneTime && a.dateTo != null)
          'untilMs': DateTime.parse(a.dateTo!)
              .add(const Duration(hours: 23, minutes: 59))
              .millisecondsSinceEpoch,
      });
      return result ?? 'unavailable';
    } on MissingPluginException {
      return 'unavailable';
    }
  }

  /// The plan's first day from [now] on (today included), at its reminder
  /// time — or 09:00 / 17:00 for a morning / evening plan without one.
  static DateTime? firstStart(RecurringActivity a, DateTime now) {
    final scheduled = a.copyWith(isActive: true);
    final hour = a.notifyHour ?? (a.shift == 'evening' ? 17 : 9);
    final minute = a.notifyHour == null ? 0 : (a.notifyMinute ?? 0);
    var d = DateTime(now.year, now.month, now.day);
    for (var i = 0; i < 400; i++) {
      if (scheduled.appliesTo(d)) {
        return DateTime(d.year, d.month, d.day, hour, minute);
      }
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return null;
  }
}
