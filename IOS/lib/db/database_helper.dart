import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/family.dart';
import '../models/entry.dart';
import '../models/recurring_activity.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'playground.db');
    return openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Schema ────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE parents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        sort_order INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE kids (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        sort_order INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE entries (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid          TEXT NOT NULL UNIQUE,
        date          TEXT NOT NULL,
        shift         TEXT NOT NULL,
        user          TEXT NOT NULL,
        vacation      INTEGER DEFAULT 0,
        no_playground INTEGER DEFAULT 0,
        duration      TEXT,
        kids          TEXT,
        activities    TEXT,
        excuse        TEXT,
        last_modified INTEGER NOT NULL,
        is_deleted    INTEGER DEFAULT 0,
        created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE tags (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        UNIQUE(type, name)
      )
    ''');
    // Stores timestamps used by the sync layer
    await db.execute('''
      CREATE TABLE sync_meta (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await _createRecurringTables(db);
  }

  Future<void> _createRecurringTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring_activities (
        id             TEXT PRIMARY KEY,
        title          TEXT NOT NULL,
        kid_names      TEXT NOT NULL DEFAULT '[]',
        repeat_days    TEXT NOT NULL DEFAULT '[]',
        date_from      TEXT,
        date_to        TEXT,
        shift          TEXT NOT NULL DEFAULT 'morning',
        is_active      INTEGER DEFAULT 1,
        notify_enabled INTEGER DEFAULT 0,
        notify_hour    INTEGER,
        notify_minute  INTEGER,
        notify_message TEXT,
        created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring_activity_logs (
        id          TEXT PRIMARY KEY,
        activity_id TEXT NOT NULL,
        date        TEXT NOT NULL,
        status      TEXT NOT NULL,
        entry_uuid  TEXT,
        skip_reason TEXT,
        created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(activity_id, date)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      try {
        await db.execute(
            'ALTER TABLE entries ADD COLUMN no_playground INTEGER DEFAULT 0');
      } catch (_) {}
    }
    if (oldVersion < 5) {
      try {
        await db.execute(
            'ALTER TABLE recurring_activities ADD COLUMN notify_message TEXT');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      // Add shift column to existing recurring_activities (safe — adds with default)
      try {
        await db.execute(
            "ALTER TABLE recurring_activities ADD COLUMN shift TEXT NOT NULL DEFAULT 'morning'");
      } catch (_) {
        // Column may already exist if table was freshly created at v3
      }
    }
    if (oldVersion < 3) {
      await _createRecurringTables(db);
    }
    if (oldVersion < 2) {
      // Add sync columns to existing entries table
      await db.execute('ALTER TABLE entries ADD COLUMN uuid TEXT');
      await db.execute('ALTER TABLE entries ADD COLUMN last_modified INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE entries ADD COLUMN is_deleted INTEGER DEFAULT 0');
      // Backfill: every existing row gets a stable UUID and "now" as lastModified
      final rows = await db.rawQuery('SELECT id FROM entries');
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final row in rows) {
        await db.update(
          'entries',
          {'uuid': Entry.generateUuid(), 'last_modified': now},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
      // Make uuid NOT NULL after backfill (SQLite doesn't support ADD CONSTRAINT,
      // but the NOT NULL will be enforced on all future inserts via _onCreate)
      await db.execute('''
        CREATE TABLE sync_meta (
          key   TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  // ── Family ────────────────────────────────────────────────

  Future<Family> getFamily() async {
    final db = await database;
    final parents = await db.query('parents', orderBy: 'sort_order, id');
    final kids = await db.query('kids', orderBy: 'sort_order, id');
    return Family(
      parents: parents.map((r) => r['name'] as String).toList(),
      kids: kids.map((r) => r['name'] as String).toList(),
    );
  }

  Future<void> saveFamily(List<String> parents, List<String> kids) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('parents');
      await txn.delete('kids');
      for (var i = 0; i < parents.length; i++) {
        await txn.insert('parents', {'name': parents[i], 'sort_order': i},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (var i = 0; i < kids.length; i++) {
        await txn.insert('kids', {'name': kids[i], 'sort_order': i},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      // Record when family config last changed — used by sync merge
      await txn.insert(
        'sync_meta',
        {'key': 'family_updated_at', 'value': '${DateTime.now().millisecondsSinceEpoch}'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // ── Tags ──────────────────────────────────────────────────

  Future<List<String>> getTags(String type) async {
    final db = await database;
    final rows = await db.query('tags',
        where: 'type = ?', whereArgs: [type], orderBy: 'id');
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<void> addTag(String type, String name) async {
    final db = await database;
    await db.insert('tags', {'type': type, 'name': name.trim()},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // ── Entries ───────────────────────────────────────────────

  Future<List<Entry>> getEntriesForDate(String date) async {
    final db = await database;
    final rows = await db.query(
      'entries',
      where: 'date = ? AND is_deleted = 0',
      whereArgs: [date],
      orderBy: 'shift, id',
    );
    return rows.map(Entry.fromMap).toList();
  }

  Future<Entry> insertEntry(Entry entry) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = entry.toMap()
      ..['uuid'] = entry.uuid.isEmpty ? Entry.generateUuid() : entry.uuid
      ..['last_modified'] = entry.lastModified == 0 ? now : entry.lastModified;
    final id = await db.insert('entries', map);
    final rows = await db.query('entries', where: 'id = ?', whereArgs: [id]);
    return Entry.fromMap(rows.first);
  }

  // Soft-delete so the deletion propagates via sync
  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.update(
      'entries',
      {'is_deleted': 1, 'last_modified': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Dashboard ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard({
    required String period,
    String? weekStart,
    String? weekEnd,
    String? month,
    String? year,
  }) async {
    final db = await database;

    String where;
    List<dynamic> args;

    switch (period) {
      case 'week':
        where = 'date >= ? AND date <= ? AND is_deleted = 0';
        args = [weekStart!, weekEnd!];
      case 'month':
        where = 'date LIKE ? AND is_deleted = 0';
        args = ['$month%'];
      case 'year':
        where = 'date LIKE ? AND is_deleted = 0';
        args = ['$year%'];
      default:
        where = 'is_deleted = 0';
        args = [];
    }

    final parentRows = await db.query('parents', orderBy: 'sort_order, id');
    final kidRows = await db.query('kids', orderBy: 'sort_order, id');
    final parents = parentRows.map((r) => r['name'] as String).toList();
    final kids = kidRows.map((r) => r['name'] as String).toList();

    final rows = await db.query('entries',
        where: where, whereArgs: args, orderBy: 'date, shift');
    final entries = rows.map(Entry.fromMap).toList();

    final byUser = {for (final p in parents) p: _countInField(entries, 'user', p)};
    final byKid = {for (final k in kids) k: _countInField(entries, 'kids', k)};

    int morning = 0, evening = 0, missed = 0;
    for (final e in entries) {
      if (e.noPlayground) {
        missed++;
      } else if (!e.vacation) {
        if (e.shift == 'morning') {
          morning++;
        } else {
          evening++;
        }
      }
    }

    return {
      'entries': entries,
      'by_user': byUser,
      'kids': byKid,
      'shifts': {'morning': morning, 'evening': evening},
      'missed': missed,
      'parents': parents,
      'kids_list': kids,
    };
  }

  int _countInField(List<Entry> entries, String field, String name) {
    return entries.where((e) {
      if (e.vacation || e.noPlayground) return false;
      final val = field == 'user' ? e.user : (e.kids ?? '');
      return val.split(',').map((s) => s.trim()).contains(name);
    }).length;
  }

  // ── Sync helpers ──────────────────────────────────────────

  Future<String?> _getMeta(String key) => getMeta(key);

  Future<String?> getMeta(String key) async {
    final db = await database;
    final rows = await db.query('sync_meta', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert('sync_meta', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Notification prefs ────────────────────────────────────

  Future<NotifPrefs> getNotifPrefs() async {
    Future<String?> g(String k) => _getMeta(k);
    return NotifPrefs(
      outdoorEnabled: (await g('notif_outdoor_on')) == '1',
      outdoorHour: int.tryParse(await g('notif_outdoor_h') ?? '') ?? 15,
      outdoorMinute: int.tryParse(await g('notif_outdoor_m') ?? '') ?? 0,
      logEnabled: (await g('notif_log_on')) == '1',
      logHour: int.tryParse(await g('notif_log_h') ?? '') ?? 20,
      logMinute: int.tryParse(await g('notif_log_m') ?? '') ?? 0,
    );
  }

  Future<void> saveNotifPrefs(NotifPrefs p) async {
    final db = await database;
    Future<void> s(String k, String v) => db.insert(
        'sync_meta', {'key': k, 'value': v},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await s('notif_outdoor_on', p.outdoorEnabled ? '1' : '0');
    await s('notif_outdoor_h', '${p.outdoorHour}');
    await s('notif_outdoor_m', '${p.outdoorMinute}');
    await s('notif_log_on', p.logEnabled ? '1' : '0');
    await s('notif_log_h', '${p.logHour}');
    await s('notif_log_m', '${p.logMinute}');
  }

  /// Returns a stable UUID for this device, creating one on first call.
  Future<String> getOrCreateDeviceId() async {
    var id = await _getMeta('device_id');
    if (id == null) {
      id = Entry.generateUuid();
      final db = await database;
      await db.insert('sync_meta', {'key': 'device_id', 'value': id},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    return id;
  }

  /// Exports all local data (including soft-deleted entries) as a JSON snapshot.
  Future<Map<String, dynamic>> exportToJson() async {
    final db = await database;
    final family = await getFamily();
    final actTags = await getTags('activity');
    final excTags = await getTags('excuse');
    final entryRows = await db.query('entries', orderBy: 'last_modified');
    final familyUpdatedAt = await _getMeta('family_updated_at') ?? '0';

    return {
      'version': 2,
      'exported_at': DateTime.now().millisecondsSinceEpoch,
      'family_updated_at': int.parse(familyUpdatedAt),
      'parents': family.parents,
      'kids': family.kids,
      'activity_tags': actTags,
      'excuse_tags': excTags,
      'entries': entryRows.map(Entry.fromMap).map((e) => e.toJsonMap()).toList(),
    };
  }

  /// Merges a remote JSON snapshot into local SQLite.
  /// Rules:
  ///   • New UUID on remote  → insert locally (unless is_deleted)
  ///   • Same UUID, remote newer → overwrite local
  ///   • Same UUID, same timestamp → keep local (local device wins tie)
  ///   • Family/tags: remote wins only if its family_updated_at > ours
  Future<void> mergeFromJson(Map<String, dynamic> remote) async {
    final db = await database;

    await db.transaction((txn) async {
      // ── Entries ──────────────────────────────────────────
      final remoteEntries = (remote['entries'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      for (final r in remoteEntries) {
        final uuid = r['uuid'] as String;
        final remoteTs = r['last_modified'] as int? ?? 0;
        final remoteDeleted = r['is_deleted'] as bool? ?? false;

        final existing = await txn.query('entries',
            where: 'uuid = ?', whereArgs: [uuid]);

        if (existing.isEmpty) {
          // New entry from remote — insert even if deleted (so we know it was deleted)
          await txn.insert('entries', {
            'uuid': uuid,
            'date': r['date'] as String,
            'shift': r['shift'] as String,
            'user': r['user'] as String,
            'vacation': (r['vacation'] as bool? ?? false) ? 1 : 0,
            'no_playground': (r['no_playground'] as bool? ?? false) ? 1 : 0,
            'duration': r['duration'] as String?,
            'kids': r['kids'] as String?,
            'activities': r['activities'] as String?,
            'excuse': r['excuse'] as String?,
            'last_modified': remoteTs,
            'is_deleted': remoteDeleted ? 1 : 0,
            'created_at': r['created_at'] as String?,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        } else {
          final localTs = existing.first['last_modified'] as int? ?? 0;
          // Remote strictly newer → take remote version
          if (remoteTs > localTs) {
            await txn.update(
              'entries',
              {
                'date': r['date'] as String,
                'shift': r['shift'] as String,
                'user': r['user'] as String,
                'vacation': (r['vacation'] as bool? ?? false) ? 1 : 0,
                'no_playground': (r['no_playground'] as bool? ?? false) ? 1 : 0,
                'duration': r['duration'] as String?,
                'kids': r['kids'] as String?,
                'activities': r['activities'] as String?,
                'excuse': r['excuse'] as String?,
                'last_modified': remoteTs,
                'is_deleted': remoteDeleted ? 1 : 0,
              },
              where: 'uuid = ?',
              whereArgs: [uuid],
            );
          }
          // remoteTs <= localTs → keep local (tie-break: local device wins)
        }
      }

      // ── Family config & tags ──────────────────────────────
      // Only overwrite if remote was updated more recently than our local config
      final localFamilyTs =
          int.tryParse(await _getMeta('family_updated_at') ?? '0') ?? 0;
      final remoteFamilyTs = remote['family_updated_at'] as int? ?? 0;

      if (remoteFamilyTs > localFamilyTs) {
        final rParents = (remote['parents'] as List? ?? []).cast<String>();
        final rKids = (remote['kids'] as List? ?? []).cast<String>();
        if (rParents.isNotEmpty && rKids.isNotEmpty) {
          await txn.delete('parents');
          await txn.delete('kids');
          for (var i = 0; i < rParents.length; i++) {
            await txn.insert('parents', {'name': rParents[i], 'sort_order': i},
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
          for (var i = 0; i < rKids.length; i++) {
            await txn.insert('kids', {'name': rKids[i], 'sort_order': i},
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
          await txn.insert('sync_meta',
              {'key': 'family_updated_at', 'value': '$remoteFamilyTs'},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Tags: always union — never remove a tag a user previously created
      for (final tag in (remote['activity_tags'] as List? ?? []).cast<String>()) {
        await txn.insert('tags', {'type': 'activity', 'name': tag},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final tag in (remote['excuse_tags'] as List? ?? []).cast<String>()) {
        await txn.insert('tags', {'type': 'excuse', 'name': tag},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  // ── Entry update (for edit-after-confirm) ─────────────────

  Future<Entry> updateEntry(Entry entry) async {
    final db = await database;
    final map = entry.toMap()
      ..['last_modified'] = DateTime.now().millisecondsSinceEpoch;
    await db.update('entries', map, where: 'uuid = ?', whereArgs: [entry.uuid]);
    final rows = await db.query('entries', where: 'uuid = ?', whereArgs: [entry.uuid]);
    return Entry.fromMap(rows.first);
  }

  Future<Entry?> getEntryByUuid(String uuid) async {
    final db = await database;
    final rows =
        await db.query('entries', where: 'uuid = ?', whereArgs: [uuid]);
    return rows.isEmpty ? null : Entry.fromMap(rows.first);
  }

  // ── Recurring activities CRUD ──────────────────────────────

  Future<List<RecurringActivity>> getAllRecurringActivities() async {
    final db = await database;
    final rows = await db.query('recurring_activities', orderBy: 'created_at');
    return rows.map(RecurringActivity.fromMap).toList();
  }

  Future<List<RecurringActivity>> getActiveRecurringActivities() async {
    final db = await database;
    final rows = await db.query('recurring_activities',
        where: 'is_active = 1', orderBy: 'created_at');
    return rows.map(RecurringActivity.fromMap).toList();
  }

  Future<void> upsertRecurringActivity(RecurringActivity a) async {
    final db = await database;
    await db.insert('recurring_activities', a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteRecurringActivity(String id) async {
    final db = await database;
    await db.delete('recurring_activities', where: 'id = ?', whereArgs: [id]);
    await db.delete('recurring_activity_logs',
        where: 'activity_id = ?', whereArgs: [id]);
  }

  // ── Recurring logs ─────────────────────────────────────────

  Future<List<RecurringLog>> getRecurringLogsForDate(String date) async {
    final db = await database;
    final rows = await db.query('recurring_activity_logs',
        where: 'date = ?', whereArgs: [date]);
    return rows.map(RecurringLog.fromMap).toList();
  }

  Future<RecurringLog> upsertRecurringLog(RecurringLog log) async {
    final db = await database;
    await db.insert('recurring_activity_logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    final rows = await db.query('recurring_activity_logs',
        where: 'activity_id = ? AND date = ?',
        whereArgs: [log.activityId, log.date]);
    return RecurringLog.fromMap(rows.first);
  }
}

// ── Notification preferences data class ──────────────────

class NotifPrefs {
  final bool outdoorEnabled;
  final int outdoorHour;
  final int outdoorMinute;
  final bool logEnabled;
  final int logHour;
  final int logMinute;

  const NotifPrefs({
    this.outdoorEnabled = false,
    this.outdoorHour = 15,   // 3 PM default
    this.outdoorMinute = 0,
    this.logEnabled = false,
    this.logHour = 20,       // 8 PM default
    this.logMinute = 0,
  });

  NotifPrefs copyWith({
    bool? outdoorEnabled,
    int? outdoorHour,
    int? outdoorMinute,
    bool? logEnabled,
    int? logHour,
    int? logMinute,
  }) =>
      NotifPrefs(
        outdoorEnabled: outdoorEnabled ?? this.outdoorEnabled,
        outdoorHour: outdoorHour ?? this.outdoorHour,
        outdoorMinute: outdoorMinute ?? this.outdoorMinute,
        logEnabled: logEnabled ?? this.logEnabled,
        logHour: logHour ?? this.logHour,
        logMinute: logMinute ?? this.logMinute,
      );
}
