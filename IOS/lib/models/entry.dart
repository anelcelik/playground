import 'dart:math';

class Entry {
  final int? id;
  final String uuid;        // stable identity across devices
  final String date;
  final String shift;
  final String user;
  final bool vacation;
  final bool noPlayground;   // nobody went — reason stored in excuse field
  final String? duration;
  final String? kids;
  final String? activities;
  final String? excuse;
  final int lastModified;   // Unix ms — last-write-wins on conflict
  final bool isDeleted;     // soft-delete so sync propagates deletions
  final String? createdAt;

  const Entry({
    this.id,
    this.uuid = '',          // empty → DatabaseHelper auto-generates on insert
    required this.date,
    required this.shift,
    required this.user,
    required this.vacation,
    this.noPlayground = false,
    this.duration,
    this.kids,
    this.activities,
    this.excuse,
    this.lastModified = 0,   // 0 → DatabaseHelper uses DateTime.now()
    this.isDeleted = false,
    this.createdAt,
  });

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? '',
      date: map['date'] as String,
      shift: map['shift'] as String,
      user: map['user'] as String,
      vacation: (map['vacation'] as int? ?? 0) == 1,
      noPlayground: (map['no_playground'] as int? ?? 0) == 1,
      duration: map['duration'] as String?,
      kids: map['kids'] as String?,
      activities: map['activities'] as String?,
      excuse: map['excuse'] as String?,
      lastModified: map['last_modified'] as int? ?? 0,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'date': date,
        'shift': shift,
        'user': user,
        'vacation': vacation ? 1 : 0,
        'no_playground': noPlayground ? 1 : 0,
        'duration': duration,
        'kids': kids,
        'activities': activities,
        'excuse': excuse,
        'last_modified': lastModified,
        'is_deleted': isDeleted ? 1 : 0,
      };

  Map<String, dynamic> toJsonMap() => {
        'uuid': uuid,
        'date': date,
        'shift': shift,
        'user': user,
        'vacation': vacation,
        'no_playground': noPlayground,
        'duration': duration,
        'kids': kids,
        'activities': activities,
        'excuse': excuse,
        'last_modified': lastModified,
        'is_deleted': isDeleted,
        'created_at': createdAt,
      };

  Entry copyWith({bool? isDeleted, int? lastModified}) => Entry(
        id: id,
        uuid: uuid,
        date: date,
        shift: shift,
        user: user,
        vacation: vacation,
        duration: duration,
        kids: kids,
        activities: activities,
        excuse: excuse,
        lastModified: lastModified ?? this.lastModified,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt,
      );

  List<String> get userList =>
      user.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  List<String> get kidList =>
      (kids ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  List<String> get activityList =>
      (activities ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  // v4 UUID — generated without external packages
  static String generateUuid() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
