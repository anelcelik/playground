// The sync cycle with the native CloudKit side replaced by a fake: what is
// sent, what is merged, and how failures are reported.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playground_tracker/db/database_helper.dart';
import 'package:playground_tracker/models/entry.dart';
import 'package:playground_tracker/models/recurring_activity.dart';
import 'package:playground_tracker/services/export_service.dart';
import 'package:playground_tracker/sync/sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.playground.tracker/cloudkit');
  final db = DatabaseHelper.instance;
  final sync = SyncService.instance;

  // What the fake iCloud answers to fetchChanges, and every call it got.
  Map<String, dynamic> remote = {};
  PlatformException? failure;
  final calls = <MethodCall>[];

  List<MethodCall> named(String method) =>
      calls.where((c) => c.method == method).toList();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseHelper.databasePathOverride = inMemoryDatabasePath;
  });

  setUp(() async {
    await DatabaseHelper.resetForTests();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    remote = {};
    failure = null;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (failure != null) throw failure!;
      return call.method == 'fetchChanges' ? jsonEncode(remote) : null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  const visit = Entry(
      date: '2026-06-01', shift: 'morning', user: 'Mom', vacation: false);
  const plan = RecurringActivity(
      id: 'football', title: 'Football', kidNames: ['Bean'], repeatDays: [0]);

  test('a sync sends what changed here, once', () async {
    await db.saveFamily(['Mom'], ['Bean']);
    await db.insertEntry(visit);
    await db.upsertRecurringActivity(plan);

    await sync.sync();
    expect(sync.status.value, SyncStatus.synced);
    expect(named('saveConfig').single.arguments['parents'], ['Mom']);
    expect((named('saveEntries').single.arguments as List).single['user'],
        'Mom');
    final records = named('saveRecords').single.arguments as List;
    expect(records.single['type'], 'PlaygroundPlan');
    expect(records.single['name'], 'plan_football');
    expect(records.single['fields']['title'], 'Football');

    calls.clear();
    await sync.sync();
    expect(calls.map((c) => c.method),
        ['fetchChanges', 'ensureSubscriptions']);
  });

  test('what the other phone changed is merged and the screens are told',
      () async {
    await db.saveFamily(['Mom'], ['Bean']);
    remote = {
      'entries': [
        {
          'uuid': 'r1',
          'date': '2026-06-02',
          'shift': 'evening',
          'user': 'Dad',
          'vacation': false,
          'last_modified': 1000,
        }
      ],
      'plans': [
        {'id': 'swim', 'title': 'Swimming', 'last_modified': 1000}
      ],
    };
    final before = sync.dataVersion.value;
    await sync.sync();
    expect(sync.dataVersion.value, before + 1);
    expect((await db.getEntriesForDate('2026-06-02')).single.user, 'Dad');
    expect((await db.getAllRecurringActivities()).single.title, 'Swimming');
    // Nothing that came from iCloud is sent back.
    expect(named('saveEntries'), isEmpty);
    expect(named('saveRecords'), isEmpty);
  });

  test('after joining a shared log everything here is sent again', () async {
    await db.saveFamily(['Mom'], ['Bean']);
    await db.insertEntry(visit);
    await sync.sync();
    calls.clear();

    remote = {'zone_changed': true, 'joined': true};
    await sync.sync();
    expect(named('saveConfig'), hasLength(1));
    expect(named('saveEntries'), hasLength(1));
  });

  test('signed out of iCloud is not an error; a failed sync is, and keeps '
      'the changes for next time', () async {
    await db.insertEntry(visit);

    failure = PlatformException(code: 'ICLOUD_UNAVAILABLE');
    await sync.sync();
    expect(sync.status.value, SyncStatus.unavailable);

    failure = PlatformException(code: 'FETCH_FAILED');
    await sync.sync();
    expect(sync.status.value, SyncStatus.error);
    expect(await db.getDirtyEntries(), hasLength(1));

    failure = null;
    await sync.sync();
    expect(sync.status.value, SyncStatus.synced);
    expect(await db.getDirtyEntries(), isEmpty);
  });

  test('the export has one row per entry, oldest first, safely quoted', () {
    final csv = ExportService.csv(const [
      Entry(
          date: '2026-06-02',
          shift: 'evening',
          user: 'Mom,Dad',
          vacation: false,
          kids: 'Bean',
          duration: '1h',
          activities: 'Slide, swings,"Sand"'),
      Entry(
          date: '2026-06-01',
          shift: 'morning',
          user: 'Mom',
          vacation: false,
          noPlayground: true,
          excuse: 'Rain'),
      Entry(date: '2026-06-03', shift: 'morning', user: 'Mom', vacation: true),
    ]);
    expect(csv.split('\r\n'), [
      'date,part of day,type,who went,kids,duration,start,end,activities,reason',
      '2026-06-01,,nobody went,,,,,,,Rain',
      '2026-06-02,evening,visit,Mom & Dad,Bean,1h,,,"Slide & swings & ""Sand""",',
      '2026-06-03,,vacation,,,,,,,',
    ]);
  });
}
