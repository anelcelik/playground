import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../db/database_helper.dart';
import '../models/recurring_activity.dart';

/// zonedSchedule() works on iOS, macOS, Android — NOT on Linux or Windows.
bool get _supportsScheduled =>
    !kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid);

const _kIdOutdoor = 1; // "Did you play outside today?"
const _kIdLog = 2;     // "Don't forget to log your visit"

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const settings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: true,
      ),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
    );
    await _plugin.initialize(settings);

    // Restore any previously saved schedule after a cold restart
    await _restoreSchedule();
  }

  /// Asks iOS for notification permission (shows system dialog on first call).
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  /// Reads saved prefs and re-schedules all enabled notifications.
  Future<void> _restoreSchedule() async {
    final p = await DatabaseHelper.instance.getNotifPrefs();
    if (p.outdoorEnabled) {
      await _schedule(
        id: _kIdOutdoor,
        title: 'Playground reminder',
        body: 'Did you take the kids outside today?',
        hour: p.outdoorHour,
        minute: p.outdoorMinute,
      );
    }
    if (p.logEnabled) {
      await _schedule(
        id: _kIdLog,
        title: 'Log your outdoor time',
        body: "Don't forget to log today's playground visit",
        hour: p.logHour,
        minute: p.logMinute,
      );
    }
    await rescheduleAllRecurring();
  }

  // ── Public API ────────────────────────────────────────────

  Future<void> scheduleOutdoor(int hour, int minute) => _schedule(
        id: _kIdOutdoor,
        title: 'Playground reminder',
        body: 'Did you take the kids outside today?',
        hour: hour,
        minute: minute,
      );

  Future<void> scheduleLog(int hour, int minute) => _schedule(
        id: _kIdLog,
        title: 'Log your outdoor time',
        body: "Don't forget to log today's playground visit",
        hour: hour,
        minute: minute,
      );

  Future<void> cancelOutdoor() => _plugin.cancel(_kIdOutdoor);
  Future<void> cancelLog() => _plugin.cancel(_kIdLog);
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Recurring activity notifications ─────────────────────

  /// Schedules one weekly notification per repeat day for [activity].
  Future<void> scheduleRecurringActivity(RecurringActivity activity) async {
    if (!_supportsScheduled) return;
    if (!activity.notifyEnabled || activity.notifyHour == null || !activity.isActive) {
      return;
    }

    await cancelRecurringActivity(activity); // clear stale ones first

    final body = (activity.notifyMessage?.trim().isNotEmpty == true)
        ? activity.notifyMessage!.trim()
        : 'Time for your recurring activity';

    for (final day in activity.repeatDays) {
      await _scheduleWeekly(
        id: activity.notifId(day),
        title: activity.title,
        body: body,
        weekday: day + 1, // our 0=Mon → Dart 1=Mon
        hour: activity.notifyHour!,
        minute: activity.notifyMinute ?? 0,
      );
    }
  }

  /// Cancels all notifications for [activity].
  Future<void> cancelRecurringActivity(RecurringActivity activity) async {
    for (final day in List.generate(7, (i) => i)) {
      await _plugin.cancel(activity.notifId(day));
    }
  }

  /// Re-schedules all active recurring activity notifications (called on launch).
  Future<void> rescheduleAllRecurring() async {
    final activities =
        await DatabaseHelper.instance.getActiveRecurringActivities();
    for (final a in activities) {
      if (a.notifyEnabled) await scheduleRecurringActivity(a);
    }
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday, // Dart weekday: 1=Mon … 7=Sun
    required int hour,
    required int minute,
  }) async {
    if (!_supportsScheduled) return;
    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
      android: AndroidNotificationDetails(
        'playground_recurring',
        'Recurring Activity Reminders',
        channelDescription: 'Reminders for recurring activities',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextWeekday(weekday, hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    var t = tz.TZDateTime.now(tz.local);
    t = tz.TZDateTime(tz.local, t.year, t.month, t.day, hour, minute);
    while (t.weekday != weekday) {
      t = t.add(const Duration(days: 1));
    }
    if (t.isBefore(tz.TZDateTime.now(tz.local))) {
      t = t.add(const Duration(days: 7));
    }
    return t;
  }

  // ── Internal scheduling ───────────────────────────────────

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_supportsScheduled) return;

    // Cancel any existing notification with this ID before rescheduling
    await _plugin.cancel(id);

    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
      android: AndroidNotificationDetails(
        'playground_reminders',
        'Playground Reminders',
        channelDescription: 'Daily reminders to log playground visits',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  /// Returns the next occurrence of [hour]:[minute] in local time.
  /// If that time already passed today, returns tomorrow's instance.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }
}
