import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playground_tracker/db/database_helper.dart';
import 'package:playground_tracker/models/entry.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // No-isolate variant: the worker-isolate factory deadlocks under
    // flutter_test, which already runs each test in its own isolate.
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseHelper.databasePathOverride = inMemoryDatabasePath;
  });

  // Fresh in-memory database for every test
  setUp(() => DatabaseHelper.resetForTests());
  tearDownAll(() => DatabaseHelper.resetForTests());

  final db = DatabaseHelper.instance;

  Entry entry({String uuid = 'u1', String date = '2026-06-01', int ts = 1000}) =>
      Entry(
        uuid: uuid,
        date: date,
        shift: 'morning',
        user: 'Mom',
        vacation: false,
        lastModified: ts,
      );

  Map<String, dynamic> remoteSnapshot({
    List<Map<String, dynamic>> entries = const [],
    List<String> deletedUuids = const [],
    int familyUpdatedAt = 0,
    List<String> parents = const [],
    List<String> kids = const [],
    List<String> activityTags = const [],
  }) =>
      {
        'entries': entries,
        'deleted_uuids': deletedUuids,
        'family_updated_at': familyUpdatedAt,
        'parents': parents,
        'kids': kids,
        'activity_tags': activityTags,
        'excuse_tags': const <String>[],
      };

  group('merge rules', () {
    test('new remote entry is inserted with needs_push = 0', () async {
      await db.mergeFromJson(remoteSnapshot(entries: [
        entry(uuid: 'remote-1', ts: 500).toJsonMap(),
      ]));

      final merged = await db.getEntryByUuid('remote-1');
      expect(merged, isNotNull);
      expect(merged!.lastModified, 500);
      // Came from the server — must not be pushed back
      expect(await db.getDirtyEntries(), isEmpty);
    });

    test('remote newer than local overwrites local', () async {
      final local = await db.insertEntry(entry(ts: 1000));
      final remote = entry(ts: 2000).toJsonMap()..['user'] = 'Dad';

      await db.mergeFromJson(remoteSnapshot(entries: [remote]));

      final merged = await db.getEntryByUuid(local.uuid);
      expect(merged!.user, 'Dad');
      expect(merged.lastModified, 2000);
    });

    test('local newer than remote is kept', () async {
      final local = await db.insertEntry(entry(ts: 3000));
      final remote = entry(ts: 2000).toJsonMap()..['user'] = 'Dad';

      await db.mergeFromJson(remoteSnapshot(entries: [remote]));

      final merged = await db.getEntryByUuid(local.uuid);
      expect(merged!.user, 'Mom');
      expect(merged.lastModified, 3000);
    });

    test('equal timestamps keep local (tie-break)', () async {
      final local = await db.insertEntry(entry(ts: 2000));
      final remote = entry(ts: 2000).toJsonMap()..['user'] = 'Dad';

      await db.mergeFromJson(remoteSnapshot(entries: [remote]));

      expect((await db.getEntryByUuid(local.uuid))!.user, 'Mom');
    });

    test('remote soft-delete propagates', () async {
      final local = await db.insertEntry(entry(ts: 1000));
      final remote = entry(ts: 2000).toJsonMap()..['is_deleted'] = true;

      await db.mergeFromJson(remoteSnapshot(entries: [remote]));

      final forDate = await db.getEntriesForDate('2026-06-01');
      expect(forDate, isEmpty, reason: 'deleted entry must not be listed');
      expect((await db.getEntryByUuid(local.uuid))!.isDeleted, isTrue);
    });

    test('server-side hard deletions (deleted_uuids) soft-delete locally',
        () async {
      final local = await db.insertEntry(entry(ts: 1000));

      await db.mergeFromJson(remoteSnapshot(deletedUuids: [local.uuid]));

      expect((await db.getEntryByUuid(local.uuid))!.isDeleted, isTrue);
      expect(await db.getDirtyEntries(), isEmpty);
    });

    test('family config: remote wins only when newer', () async {
      await db.saveFamily(['Mom', 'Dad'], ['Kid A']);

      // Older remote config → ignored
      await db.mergeFromJson(remoteSnapshot(
          familyUpdatedAt: 1, parents: ['X'], kids: ['Y']));
      expect((await db.getFamily()).parents, ['Mom', 'Dad']);

      // Newer remote config → applied
      final future = DateTime.now().millisecondsSinceEpoch + 100000;
      await db.mergeFromJson(remoteSnapshot(
          familyUpdatedAt: future, parents: ['X'], kids: ['Y']));
      expect((await db.getFamily()).parents, ['X']);
      expect((await db.getFamily()).kids, ['Y']);
    });

    test('tags are unioned, never removed', () async {
      await db.addTag('activity', 'Swings');
      await db.mergeFromJson(remoteSnapshot(activityTags: ['Slide']));
      expect(await db.getTags('activity'),
          containsAll(<String>['Swings', 'Slide']));
    });
  });

  group('dirty-flag push tracking', () {
    test('insert, update and delete mark entries dirty', () async {
      final e = await db.insertEntry(entry());
      expect((await db.getDirtyEntries()).map((d) => d.uuid), [e.uuid]);

      await db.markEntriesPushed(
          [(uuid: e.uuid, lastModified: e.lastModified)]);
      expect(await db.getDirtyEntries(), isEmpty);

      await db.updateEntry(e);
      expect(await db.getDirtyEntries(), hasLength(1));

      final updated = (await db.getDirtyEntries()).first;
      await db.markEntriesPushed(
          [(uuid: updated.uuid, lastModified: updated.lastModified)]);

      await db.deleteEntry(e.id!);
      expect(await db.getDirtyEntries(), hasLength(1));
    });

    test('edit during in-flight push keeps the entry dirty', () async {
      final e = await db.insertEntry(entry());

      // Simulate: push started with this snapshot…
      final snapshotTs = e.lastModified;
      // …but the user edits before the push completes (bumps last_modified)
      await db.updateEntry(e);

      await db.markEntriesPushed([(uuid: e.uuid, lastModified: snapshotTs)]);
      expect(await db.getDirtyEntries(), hasLength(1),
          reason: 'newer edit must survive the stale push confirmation');
    });

    test('config dirty lifecycle', () async {
      expect(await db.isConfigDirty(), isTrue,
          reason: 'fresh install pushes config once');
      await db.markConfigPushed();
      expect(await db.isConfigDirty(), isFalse);
      await db.saveFamily(['Mom'], ['Kid']);
      expect(await db.isConfigDirty(), isTrue);
    });
  });

  group('input sanitisation', () {
    test('commas are stripped from names and tags', () async {
      await db.saveFamily(['Mom, the great', '  '], ['A,B']);
      final family = await db.getFamily();
      expect(family.parents, ['Mom the great']);
      expect(family.kids, ['A B']);

      await db.addTag('activity', 'run, jump');
      expect(await db.getTags('activity'), ['run jump']);
    });
  });

  group('export', () {
    test('exportConfig round-trips family and tags', () async {
      await db.saveFamily(['Mom', 'Dad'], ['Kid']);
      await db.addTag('activity', 'Swings');

      final config = await db.exportConfig();
      expect(config['parents'], ['Mom', 'Dad']);
      expect(config['kids'], ['Kid']);
      expect(config['activity_tags'], ['Swings']);
      expect(config['family_updated_at'], greaterThan(0));
    });
  });
}
