import 'package:flutter/services.dart';

import '../models/recurring_activity.dart';

/// "Add to Calendar" and "Add to Reminders" for a plan, iOS only
/// (CalendarBridge in AppDelegate.swift). Calendar opens the system New Event
/// sheet prefilled with the plan's title, first day, time and weekly repeat;
/// apps cannot send invitations themselves, so invitees are added in that
/// sheet. Reminders has no such sheet: the reminder is saved directly, with
/// an alert at the plan's time.
class CalendarService {
  static const _channel = MethodChannel('com.playground.tracker/calendar');

  /// 'saved' | 'cancelled' | 'denied' | 'unavailable' (not on iPhone) |
  /// 'none' (the plan has no day left to add).
  static Future<String> addPlan(RecurringActivity a) =>
      _add('addEvent', a, DateTime.now());

  /// Like [addPlan]; 'error' if Reminders refused to save. Starts at the next
  /// time still ahead, so it is not overdue the moment it is added.
  static Future<String> addReminder(RecurringActivity a) {
    final now = DateTime.now();
    final start = firstStart(a, now);
    return _add('addReminder', a,
        start != null && start.isBefore(now)
            ? DateTime(now.year, now.month, now.day + 1)
            : now);
  }

  /// The line shown after adding, or null when there is nothing to say.
  static String? message(String result, {required bool reminders}) {
    final app = reminders ? 'Reminders' : 'Calendar';
    return switch (result) {
      'saved' => reminders ? 'Added to Reminders' : 'Added to your calendar',
      'denied' => '$app access is off. Allow it in iPhone Settings.',
      'none' => 'This plan has no upcoming day to add',
      'unavailable' => '$app is only available on iPhone',
      'error' => 'Could not add to $app',
      _ => null, // cancelled
    };
  }

  static Future<String> _add(
      String method, RecurringActivity a, DateTime from) async {
    final start = firstStart(a, from);
    if (start == null) return 'none';
    try {
      final result = await _channel.invokeMethod<String>(method, {
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
