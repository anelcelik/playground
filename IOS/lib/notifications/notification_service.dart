import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../db/database_helper.dart';
import '../models/recurring_activity.dart';
import '../l10n/l10n.dart';

/// zonedSchedule() works on iOS, macOS, Android — NOT on Linux or Windows.
bool get _supportsScheduled =>
    !kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid);

// Notification ids.
//   11–17  "Did you play outside today?", one per weekday (Mon = 11)
//   18     the same, one week ahead, while today's is switched off
//   21–27  "Don't forget to log your visit", one per weekday
//   28     its one-week-ahead stand-in
//   1000+  plans (RecurringActivity.notifBase), 15 per plan
// Ids 1 and 2 and the old plan ids are from before; see _migrate.
const _kOutdoorBase = 10;
const _kLogBase = 20;
const _kBridgeSlot = 8;

/// How many dated reminders a plan with a start or end date gets ahead of
/// time. The rest follow the next time the app is opened.
const _kPlanDates = 8;

const _kDetails = NotificationDetails(
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    // iOS 14+ ignores presentAlert while the app is open: without banner
    // and list a reminder due then was dropped, not even kept in the list.
    presentBanner: true,
    presentList: true,
    presentBadge: false,
    presentSound: true,
    interruptionLevel: InterruptionLevel.active,
  ),
  android: AndroidNotificationDetails(
    'playground_reminders',
    'Playground Reminders',
    channelDescription: 'Reminders to go outside, to log, and for plans',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  ),
);

/// When a plan's reminder should ring. Null: every week on the plan's days,
/// which is right for a plan without dates. A plan that starts later or
/// ends on a date gets its next [max] moments instead, because a weekly
/// repeat knows nothing about dates and would ring before the first day
/// and after the last.
List<DateTime>? planReminderMoments(RecurringActivity a, DateTime now,
    {int max = _kPlanDates}) {
  final today = DateTime(now.year, now.month, now.day);
  final from = a.dateFrom == null ? null : DateTime.parse(a.dateFrom!);
  final to = a.dateTo == null ? null : DateTime.parse(a.dateTo!);
  if (to == null && (from == null || !from.isAfter(today))) return null;

  final out = <DateTime>[];
  var d = from != null && from.isAfter(today) ? from : today;
  for (var i = 0; i < 400 && out.length < max; i++) {
    if (to != null && d.isAfter(to)) break;
    if (a.repeatDays.contains(d.weekday - 1)) {
      final moment = DateTime(
          d.year, d.month, d.day, a.notifyHour ?? 0, a.notifyMinute ?? 0);
      if (moment.isAfter(now)) out.add(moment);
    }
    d = DateTime(d.year, d.month, d.day + 1);
  }
  return out;
}

/// A daily reminder is pointless once the day is logged: true while today
/// has an entry and the reminder's time is still ahead.
bool skipTodaysReminder(DateTime now, int hour, int minute,
        {required bool loggedToday}) =>
    loggedToday &&
    now.isBefore(DateTime(now.year, now.month, now.day, hour, minute));

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // One refresh of the daily reminders at a time, in the order asked.
  Future<void> _dailyQueue = Future.value();
  String? _plansScheduledOn;

  Future<void> init() async {
    // No permission prompt at launch: iOS asks when someone first turns a
    // reminder on (requestPermission), so the request has its context.
    const settings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
    );
    await _plugin.initialize(settings);
    await _migrate();

    // Restore any previously saved schedule after a cold restart
    await restoreSchedule();
  }

  /// Earlier versions used other ids (a single daily one, and plan ids from
  /// a hash that could change with the Flutter version). Clear them once;
  /// restoreSchedule puts everything back under the ids above.
  Future<void> _migrate() async {
    if (!_supportsScheduled) return;
    if (await DatabaseHelper.instance.getMeta('notif_scheme') == '2') return;
    await _plugin.cancelAll();
    await DatabaseHelper.instance.setMeta('notif_scheme', '2');
  }

  /// Whether notifications are allowed, without ever showing the prompt.
  /// True off iOS, where nothing gates scheduling.
  Future<bool> hasPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios == null) return true;
    return (await ios.checkPermissions())?.isEnabled ?? false;
  }

  /// Asks iOS for notification permission (shows system dialog on first call).
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  /// Re-schedules everything from the saved settings (launch, and when the
  /// language changes, so the texts follow).
  Future<void> restoreSchedule() async {
    await refreshDaily();
    await rescheduleAllRecurring();
  }

  /// The app came back to the foreground: today may be another day than
  /// when the reminders were last set.
  Future<void> onResume() async {
    await refreshDaily();
    if (_plansScheduledOn != _today()) await rescheduleAllRecurring();
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  static String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ── Daily reminders ───────────────────────────────────────

  /// Sets the two daily reminders from the saved settings. Called whenever
  /// they or today's entries change: a day that is already logged gets no
  /// "did you go outside?" and no "don't forget to log".
  Future<void> refreshDaily() {
    if (!_supportsScheduled) return Future.value();
    final run = _dailyQueue.then((_) => _refreshDaily());
    _dailyQueue = run.catchError((Object e) {
      debugPrint('[notifications] refreshDaily failed: $e');
    });
    return _dailyQueue;
  }

  Future<void> _refreshDaily() async {
    if (!_supportsScheduled) return;
    final db = DatabaseHelper.instance;
    final p = await db.getNotifPrefs();
    final logged = (await db.getEntriesForDate(_today())).isNotEmpty;
    final l = currentL10n;
    await _setDaily(_kOutdoorBase, p.outdoorEnabled, p.outdoorHour,
        p.outdoorMinute, l.notifOutdoorTitle, l.notifOutdoorBody, logged);
    await _setDaily(_kLogBase, p.logEnabled, p.logHour, p.logMinute,
        l.notifLogTitle, l.notifLogBody, logged);
  }

  /// One weekly repeat per weekday instead of a single daily one, so that
  /// today's can be left out. While it is, a single reminder a week ahead
  /// stands in for it, in case the app isn't opened again before then.
  Future<void> _setDaily(int base, bool enabled, int hour, int minute,
      String title, String body, bool loggedToday) async {
    await _plugin.cancel(base + _kBridgeSlot);
    final now = DateTime.now();
    final skipToday =
        skipTodaysReminder(now, hour, minute, loggedToday: loggedToday);
    for (var weekday = 1; weekday <= 7; weekday++) {
      final id = base + weekday;
      if (!enabled) {
        await _plugin.cancel(id);
      } else if (skipToday && weekday == now.weekday) {
        await _plugin.cancel(id);
        await _scheduleOnce(
            id: base + _kBridgeSlot,
            title: title,
            body: body,
            at: DateTime(now.year, now.month, now.day + 7, hour, minute));
      } else {
        await _scheduleWeekly(
            id: id,
            title: title,
            body: body,
            weekday: weekday,
            hour: hour,
            minute: minute);
      }
    }
  }

  // ── Plan reminders ────────────────────────────────────────

  /// Sets [activity]'s reminder: weekly on its days, or on its exact dates
  /// when it has a start or end date (planReminderMoments). Clears it when
  /// the reminder is off or the plan is paused.
  Future<void> scheduleRecurringActivity(RecurringActivity activity) async {
    if (!_supportsScheduled) return;
    await cancelRecurringActivity(activity); // clear stale ones first
    if (!activity.notifyEnabled ||
        activity.notifyHour == null ||
        !activity.isActive) {
      return;
    }

    final body = (activity.notifyMessage?.trim().isNotEmpty == true)
        ? activity.notifyMessage!.trim()
        : currentL10n.notifPlanDefaultBody;

    final moments = planReminderMoments(activity, DateTime.now());
    if (moments == null) {
      for (final day in activity.repeatDays) {
        await _scheduleWeekly(
          id: activity.notifBase + day,
          title: activity.title,
          body: body,
          weekday: day + 1, // our 0=Mon → Dart 1=Mon
          hour: activity.notifyHour!,
          minute: activity.notifyMinute ?? 0,
        );
      }
      return;
    }
    for (var i = 0; i < moments.length; i++) {
      await _scheduleOnce(
          id: activity.notifBase + 7 + i,
          title: activity.title,
          body: body,
          at: moments[i]);
    }
  }

  /// Cancels all notifications for [activity].
  Future<void> cancelRecurringActivity(RecurringActivity activity) async {
    if (!_supportsScheduled) return;
    for (var slot = 0; slot < 7 + _kPlanDates; slot++) {
      await _plugin.cancel(activity.notifBase + slot);
    }
  }

  /// Re-schedules all active recurring activity notifications (launch, and
  /// the first time the app is opened on a new day, which moves a dated
  /// plan's reminders along).
  Future<void> rescheduleAllRecurring() async {
    _plansScheduledOn = _today();
    final activities =
        await DatabaseHelper.instance.getActiveRecurringActivities();
    for (final a in activities) {
      if (a.notifyEnabled) await scheduleRecurringActivity(a);
    }
  }

  // ── Scheduling ────────────────────────────────────────────

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday, // Dart weekday: 1=Mon … 7=Sun
    required int hour,
    required int minute,
  }) async {
    if (!_supportsScheduled) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextWeekday(weekday, hour, minute),
      _kDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> _scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    if (!_supportsScheduled) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime(tz.local, at.year, at.month, at.day, at.hour, at.minute),
      _kDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
}
