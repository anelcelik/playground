import 'dart:convert';
import 'entry.dart';

// ── Recurring activity definition ─────────────────────────

class RecurringActivity {
  final String id;
  final String title;
  final List<String> kidNames;   // names, not UUIDs — matches kids table
  final List<int> repeatDays;    // 0 = Mon … 6 = Sun
  final String? dateFrom;        // YYYY-MM-DD, inclusive, nullable
  final String? dateTo;          // YYYY-MM-DD, inclusive, nullable
  final String shift;         // 'morning' | 'evening'
  final bool isActive;
  final bool notifyEnabled;
  final int? notifyHour;
  final int? notifyMinute;
  final String? notifyMessage;  // custom notification body, null = default
  final String? createdAt;

  const RecurringActivity({
    required this.id,
    required this.title,
    required this.kidNames,
    required this.repeatDays,
    this.dateFrom,
    this.dateTo,
    this.shift = 'morning',
    this.isActive = true,
    this.notifyEnabled = false,
    this.notifyHour,
    this.notifyMinute,
    this.notifyMessage,
    this.createdAt,
  });

  factory RecurringActivity.fromMap(Map<String, dynamic> m) => RecurringActivity(
        id: m['id'] as String,
        title: m['title'] as String,
        kidNames: List<String>.from(jsonDecode(m['kid_names'] as String? ?? '[]')),
        repeatDays: List<int>.from(jsonDecode(m['repeat_days'] as String? ?? '[]')),
        dateFrom: m['date_from'] as String?,
        dateTo: m['date_to'] as String?,
        shift: m['shift'] as String? ?? 'morning',
        isActive: (m['is_active'] as int? ?? 1) == 1,
        notifyEnabled: (m['notify_enabled'] as int? ?? 0) == 1,
        notifyHour: m['notify_hour'] as int?,
        notifyMinute: m['notify_minute'] as int?,
        notifyMessage: m['notify_message'] as String?,
        createdAt: m['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'kid_names': jsonEncode(kidNames),
        'repeat_days': jsonEncode(repeatDays),
        'date_from': dateFrom,
        'date_to': dateTo,
        'shift': shift,
        'is_active': isActive ? 1 : 0,
        'notify_enabled': notifyEnabled ? 1 : 0,
        'notify_hour': notifyHour,
        'notify_minute': notifyMinute,
        'notify_message': notifyMessage,
      };

  RecurringActivity copyWith({
    String? title,
    List<String>? kidNames,
    List<int>? repeatDays,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    String? shift,
    bool? isActive,
    bool? notifyEnabled,
    Object? notifyHour = _sentinel,
    Object? notifyMinute = _sentinel,
    Object? notifyMessage = _sentinel,
  }) =>
      RecurringActivity(
        id: id,
        title: title ?? this.title,
        kidNames: kidNames ?? this.kidNames,
        repeatDays: repeatDays ?? this.repeatDays,
        dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as String?,
        dateTo: dateTo == _sentinel ? this.dateTo : dateTo as String?,
        shift: shift ?? this.shift,
        isActive: isActive ?? this.isActive,
        notifyEnabled: notifyEnabled ?? this.notifyEnabled,
        notifyHour:
            notifyHour == _sentinel ? this.notifyHour : notifyHour as int?,
        notifyMinute:
            notifyMinute == _sentinel ? this.notifyMinute : notifyMinute as int?,
        notifyMessage:
            notifyMessage == _sentinel ? this.notifyMessage : notifyMessage as String?,
        createdAt: createdAt,
      );

  /// Does this activity apply to [date]?
  bool appliesTo(DateTime date) {
    if (!isActive) return false;
    final day = date.weekday - 1; // DateTime: 1=Mon → our: 0=Mon
    if (!repeatDays.contains(day)) return false;
    if (dateFrom != null) {
      final from = DateTime.parse(dateFrom!);
      if (date.isBefore(DateTime(from.year, from.month, from.day))) return false;
    }
    if (dateTo != null) {
      final to = DateTime.parse(dateTo!);
      if (date.isAfter(DateTime(to.year, to.month, to.day))) return false;
    }
    return true;
  }

  String get repeatDaysLabel {
    if (repeatDays.isEmpty) return 'No days';
    const n = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final s = repeatDays.toSet();
    if (s.length == 7) return 'Every day';
    if ({0, 1, 2, 3, 4}.every(s.contains) && s.length == 5) return 'Weekdays';
    if ({5, 6}.every(s.contains) && s.length == 2) return 'Weekends';
    return ([...repeatDays]..sort()).map((d) => n[d]).join(', ');
  }

  String get notifyTimeLabel {
    if (notifyHour == null) return '';
    final h = notifyHour! % 12 == 0 ? 12 : notifyHour! % 12;
    final m = notifyMinute.toString().padLeft(2, '0');
    final p = notifyHour! < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  /// Stable notification ID for (this activity, dayOfWeek), range 100–9099.
  int notifId(int dayOfWeek) =>
      100 + (id.hashCode.abs() * 7 + dayOfWeek) % 9000;
}

const _sentinel = Object();

// ── Log record (one per activity per day) ─────────────────

class RecurringLog {
  final String id;
  final String activityId;
  final String date;
  final String status;    // 'confirmed' | 'skipped' | 'missed'
  final String? entryUuid;
  final String? skipReason; // 'sick' | 'cancelled' | 'other'
  final String? createdAt;

  const RecurringLog({
    required this.id,
    required this.activityId,
    required this.date,
    required this.status,
    this.entryUuid,
    this.skipReason,
    this.createdAt,
  });

  factory RecurringLog.fromMap(Map<String, dynamic> m) => RecurringLog(
        id: m['id'] as String,
        activityId: m['activity_id'] as String,
        date: m['date'] as String,
        status: m['status'] as String,
        entryUuid: m['entry_uuid'] as String?,
        skipReason: m['skip_reason'] as String?,
        createdAt: m['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'activity_id': activityId,
        'date': date,
        'status': status,
        'entry_uuid': entryUuid,
        'skip_reason': skipReason,
      };
}

// ── Combined view for a specific date ─────────────────────

class RecurringActivityStatus {
  final RecurringActivity activity;
  final RecurringLog? log;   // null = pending (today) or not yet processed
  final Entry? entry;        // populated when status == confirmed

  const RecurringActivityStatus({
    required this.activity,
    this.log,
    this.entry,
  });

  bool get isPending => log == null;
  bool get isConfirmed => log?.status == 'confirmed';
  bool get isSkipped => log?.status == 'skipped';
  bool get isMissed => log?.status == 'missed';
}
