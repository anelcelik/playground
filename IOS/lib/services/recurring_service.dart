import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../models/recurring_activity.dart';

class RecurringService {
  static final RecurringService instance = RecurringService._();
  RecurringService._();

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool _isPast(String date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime.parse(date);
    return d.isBefore(today);
  }

  /// Returns all recurring activities that apply to [date], each with status.
  /// Also lazily marks past-unresolved activities as missed.
  Future<List<RecurringActivityStatus>> getStatusForDate(String date) async {
    final dateObj = DateTime.parse(date);
    final activities = await DatabaseHelper.instance.getActiveRecurringActivities();
    final applicable =
        activities.where((a) => a.appliesTo(dateObj)).toList();
    if (applicable.isEmpty) return [];

    final logs = await DatabaseHelper.instance.getRecurringLogsForDate(date);
    final logMap = {for (final l in logs) l.activityId: l};

    final result = <RecurringActivityStatus>[];
    for (final activity in applicable) {
      var log = logMap[activity.id];

      // Auto-mark as missed if date has passed and no action was taken
      if (log == null && _isPast(date)) {
        log = await DatabaseHelper.instance.upsertRecurringLog(RecurringLog(
          id: Entry.generateUuid(),
          activityId: activity.id,
          date: date,
          status: 'missed',
        ));
      }

      Entry? entry;
      if (log?.entryUuid != null) {
        entry = await DatabaseHelper.instance.getEntryByUuid(log!.entryUuid!);
      }
      result.add(RecurringActivityStatus(
          activity: activity, log: log, entry: entry));
    }
    return result;
  }

  /// Confirm an activity: creates a log Entry and a RecurringLog record.
  /// Returns the created Entry so the UI can update immediately.
  Future<RecurringActivityStatus> confirm({
    required RecurringActivity activity,
    required String date,
    required Family family,
  }) async {
    final userStr = family.parents.join(',');
    final kidStr = activity.kidNames.join(',');
    final now = DateTime.now().millisecondsSinceEpoch;

    final entry = await DatabaseHelper.instance.insertEntry(Entry(
      date: date,
      shift: activity.shift,
      user: userStr,
      vacation: false,
      kids: kidStr.isEmpty ? null : kidStr,
      activities: activity.title,
      lastModified: now,
    ));

    final log = await DatabaseHelper.instance.upsertRecurringLog(RecurringLog(
      id: Entry.generateUuid(),
      activityId: activity.id,
      date: date,
      status: 'confirmed',
      entryUuid: entry.uuid,
    ));

    return RecurringActivityStatus(activity: activity, log: log, entry: entry);
  }

  /// Skip an activity: records reason without creating an Entry.
  Future<RecurringActivityStatus> skip({
    required RecurringActivity activity,
    required String date,
    required String reason,
  }) async {
    final log = await DatabaseHelper.instance.upsertRecurringLog(RecurringLog(
      id: Entry.generateUuid(),
      activityId: activity.id,
      date: date,
      status: 'skipped',
      skipReason: reason,
    ));
    return RecurringActivityStatus(activity: activity, log: log);
  }

  /// Runs on app launch — marks any past unresolved activities as missed
  /// for the last [lookbackDays] days.
  Future<void> autoMarkMissed({int lookbackDays = 7}) async {
    final activities =
        await DatabaseHelper.instance.getActiveRecurringActivities();
    if (activities.isEmpty) return;

    final today = DateTime.now();
    for (var i = 1; i <= lookbackDays; i++) {
      final d = today.subtract(Duration(days: i));
      final date = _fmt(d);
      final applicable = activities.where((a) => a.appliesTo(d)).toList();
      if (applicable.isEmpty) continue;

      final logs =
          await DatabaseHelper.instance.getRecurringLogsForDate(date);
      final loggedIds = logs.map((l) => l.activityId).toSet();

      for (final activity in applicable) {
        if (!loggedIds.contains(activity.id)) {
          await DatabaseHelper.instance.upsertRecurringLog(RecurringLog(
            id: Entry.generateUuid(),
            activityId: activity.id,
            date: date,
            status: 'missed',
          ));
        }
      }
    }
  }
}
