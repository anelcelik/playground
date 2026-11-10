import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playground_tracker/db/database_helper.dart';
import 'package:playground_tracker/models/entry.dart';
import 'package:playground_tracker/models/family.dart';
import 'package:playground_tracker/models/goal.dart';
import 'package:playground_tracker/models/recurring_activity.dart';
import 'package:playground_tracker/services/data_reset.dart';
import 'package:playground_tracker/services/recurring_service.dart';
import 'package:playground_tracker/settings/app_settings.dart';
import 'package:playground_tracker/theme.dart';

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

    test('merge says whether the screens have something new to show',
        () async {
      // Nothing in it
      expect(await db.mergeFromJson(remoteSnapshot()), isFalse);
      // A visit from the other phone
      expect(
          await db.mergeFromJson(remoteSnapshot(
              entries: [entry(uuid: 'remote-1', ts: 500).toJsonMap()])),
          isTrue);
      // The same visit again: already here
      expect(
          await db.mergeFromJson(remoteSnapshot(
              entries: [entry(uuid: 'remote-1', ts: 500).toJsonMap()])),
          isFalse);
      // Names changed on the other phone
      final future = DateTime.now().millisecondsSinceEpoch + 100000;
      expect(
          await db.mergeFromJson(remoteSnapshot(
              familyUpdatedAt: future, parents: ['X'], kids: ['Y'])),
          isTrue);
    });

    test('joining a shared log: its names win, own visits are pushed again',
        () async {
      await db.saveFamily(['Me'], ['Kid']);
      final mine = await db.insertEntry(entry(uuid: 'mine'));
      await db.markEntriesPushed(
          [(uuid: mine.uuid, lastModified: mine.lastModified)]);
      await db.markConfigPushed();
      expect(await db.getDirtyEntries(), isEmpty);

      // What SyncService does when the native side reports the switch
      await db.markAllForPush();
      await db.setMeta('family_updated_at', '0');
      // The owner set the names up long before this phone did
      await db.mergeFromJson(remoteSnapshot(
          familyUpdatedAt: 1000, parents: ['Mom', 'Dad'], kids: ['Mia']));

      expect((await db.getFamily()).parents, ['Mom', 'Dad']);
      expect((await db.getDirtyEntries()).map((e) => e.uuid), ['mine']);
      expect(await db.isConfigDirty(), isTrue);
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

  test('a nobody-went reason can be changed afterwards', () async {
    final saved = await db.insertEntry(const Entry(
      uuid: 'n1',
      date: '2026-06-01',
      shift: 'morning',
      user: 'Mom',
      vacation: false,
      noPlayground: true,
      excuse: 'Rain',
      lastModified: 1000,
    ));
    final updated =
        await db.updateEntry(saved.copyWith(excuse: 'Grandma visiting'));
    expect(updated.excuse, 'Grandma visiting');
    expect(updated.noPlayground, isTrue);
  });

  test('Done on an indoor plan logs no visit; an outdoor one does', () async {
    const family = Family(parents: ['Mom'], kids: ['Bean']);
    const piano = RecurringActivity(
        id: 'piano', title: 'Piano', kidNames: ['Bean'], repeatDays: [0],
        outdoor: false);
    const football = RecurringActivity(
        id: 'football', title: 'Football', kidNames: ['Bean'], repeatDays: [0]);
    await db.upsertRecurringActivity(piano);
    await db.upsertRecurringActivity(football);
    expect((await db.getAllRecurringActivities())
        .firstWhere((a) => a.id == 'piano').outdoor, isFalse);

    // 2026-06-01 is a Monday.
    final indoor = await RecurringService.instance
        .confirm(activity: piano, date: '2026-06-01', family: family);
    expect(indoor.entry, isNull);
    expect(indoor.log!.status, 'confirmed');
    final outdoor = await RecurringService.instance
        .confirm(activity: football, date: '2026-06-01', family: family);
    expect(outdoor.entry!.activities, 'Football');

    final day = await db.getEntriesForDate('2026-06-01');
    expect(day.map((e) => e.activities), ['Football']);
    final status =
        await RecurringService.instance.getStatusForDate('2026-06-01');
    expect(status.every((s) => s.isConfirmed), isTrue);
  });

  group('plan sync', () {
    const football = RecurringActivity(
        id: 'football',
        title: 'Football',
        kidNames: ['Bean'],
        repeatDays: [0],
        notifyEnabled: true,
        notifyHour: 16,
        notifyMinute: 30);

    Map<String, dynamic> remotePlan(int ts,
            {String title = 'Football', int deleted = 0, int active = 1}) =>
        {
          'id': 'football',
          'title': title,
          'kid_names': '["Bean"]',
          'repeat_days': '[0,2]',
          'date_from': '',
          'date_to': '',
          'shift': 'evening',
          'outdoor': 1,
          'is_active': active,
          'created_at': '2026-05-01 10:00:00',
          'last_modified': ts,
          'is_deleted': deleted,
        };

    Map<String, dynamic> remoteLog(String status, int ts, {String reason = ''}) =>
        {
          'id': 'remote-log',
          'activity_id': 'football',
          'date': '2026-06-01',
          'status': status,
          'entry_uuid': '',
          'skip_reason': reason,
          'last_modified': ts,
        };

    test('making, changing and deleting a plan marks it for push', () async {
      await db.upsertRecurringActivity(football);
      var dirty = await db.getDirtyPlans();
      expect(dirty.single['title'], 'Football');
      expect(dirty.single['date_from'], '');
      await db.markPlansPushed(dirty, []);
      expect(await db.getDirtyPlans(), isEmpty);

      await db.upsertRecurringActivity(football.copyWith(title: 'Soccer'));
      dirty = await db.getDirtyPlans();
      expect(dirty.single['title'], 'Soccer');
      await db.markPlansPushed(dirty, []);

      await db.deleteRecurringActivity('football');
      expect(await db.getAllRecurringActivities(), isEmpty);
      expect(await db.getRecurringActivity('football'), isNull);
      expect((await db.getDirtyPlans()).single['is_deleted'], 1);
    });

    test('a change made while the push was running stays marked', () async {
      await db.upsertRecurringActivity(football);
      final sent = await db.getDirtyPlans();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await db.upsertRecurringActivity(football.copyWith(title: 'Soccer'));
      await db.markPlansPushed(sent, []);
      expect((await db.getDirtyPlans()).single['title'], 'Soccer');
    });

    test('a plan from the other phone arrives with its reminder off',
        () async {
      final changed = await db.mergeFromJson({
        'plans': [remotePlan(1000)]
      });
      expect(changed, isTrue);
      final plan = (await db.getAllRecurringActivities()).single;
      expect(plan.title, 'Football');
      expect(plan.repeatDays, [0, 2]);
      expect(plan.shift, 'evening');
      expect(plan.dateFrom, isNull);
      expect(plan.notifyEnabled, isFalse);
      expect(plan.createdAt, '2026-05-01 10:00:00');
      expect(await db.getDirtyPlans(), isEmpty);
    });

    test('a newer change from the other phone keeps this phone’s reminder',
        () async {
      await db.upsertRecurringActivity(football);
      final far = DateTime.now().millisecondsSinceEpoch + 100000;

      // Older than what is here: ignored.
      expect(
          await db.mergeFromJson({
            'plans': [remotePlan(5, title: 'Old')]
          }),
          isFalse);
      expect((await db.getAllRecurringActivities()).single.title, 'Football');

      await db.mergeFromJson({
        'plans': [remotePlan(far, title: 'Soccer', active: 0)]
      });
      final plan = (await db.getAllRecurringActivities()).single;
      expect(plan.title, 'Soccer');
      expect(plan.isActive, isFalse);
      expect(plan.notifyEnabled, isTrue);
      expect(plan.notifyHour, 16);
      expect(await db.getDirtyPlans(), isEmpty);
    });

    test('a plan deleted on the other phone goes here too, with its days',
        () async {
      const family = Family(parents: ['Mom'], kids: ['Bean']);
      await db.upsertRecurringActivity(football);
      await RecurringService.instance
          .confirm(activity: football, date: '2026-06-01', family: family);
      final far = DateTime.now().millisecondsSinceEpoch + 100000;

      await db.mergeFromJson({
        'plans': [remotePlan(far, deleted: 1)],
        // A day of the deleted plan that is still in iCloud is not kept.
        'plan_logs': [remoteLog('confirmed', far)],
      });
      expect(await db.getAllRecurringActivities(), isEmpty);
      expect(await db.getRecurringLogsForActivity('football'), isEmpty);
      // The visit that Done logged stays in the history.
      expect((await db.getEntriesForDate('2026-06-01')).length, 1);
    });

    test('Done and Skip are pushed; a day nobody marked is not', () async {
      await db.upsertRecurringActivity(football);
      // 2026-06-01 is a Monday in the past: counted as missed.
      final status =
          await RecurringService.instance.getStatusForDate('2026-06-01');
      expect(status.single.isMissed, isTrue);
      expect(await db.getDirtyPlanLogs(), isEmpty);

      await RecurringService.instance
          .skip(activity: football, date: '2026-06-01', reason: 'sick');
      final dirty = await db.getDirtyPlanLogs();
      expect(dirty.single['status'], 'skipped');
      expect(dirty.single['skip_reason'], 'sick');
      expect(dirty.single['entry_uuid'], '');
      await db.markPlansPushed([], dirty);
      expect(await db.getDirtyPlanLogs(), isEmpty);
    });

    test('what the other phone marked replaces a day assumed missed',
        () async {
      await db.upsertRecurringActivity(football);
      await RecurringService.instance.getStatusForDate('2026-06-01');

      // Marked before this phone wrote its "missed": still wins.
      final changed = await db.mergeFromJson({
        'plan_logs': [remoteLog('confirmed', 5)]
      });
      expect(changed, isTrue);
      final log = (await db.getRecurringLogsForActivity('football')).single;
      expect(log.status, 'confirmed');
      expect(await db.getDirtyPlanLogs(), isEmpty);
    });

    test('for a day marked on both phones the later one counts', () async {
      await db.upsertRecurringActivity(football);
      await RecurringService.instance
          .skip(activity: football, date: '2026-06-01', reason: 'sick');
      final far = DateTime.now().millisecondsSinceEpoch + 100000;

      expect(
          await db.mergeFromJson({
            'plan_logs': [remoteLog('confirmed', 5)]
          }),
          isFalse);
      expect((await db.getRecurringLogsForActivity('football')).single.status,
          'skipped');

      await db.mergeFromJson({
        'plan_logs': [remoteLog('skipped', far, reason: 'cancelled')]
      });
      final log = (await db.getRecurringLogsForActivity('football')).single;
      expect(log.skipReason, 'cancelled');
    });

    test('joining a shared log pushes this phone’s plans again', () async {
      await db.upsertRecurringActivity(football);
      await RecurringService.instance
          .skip(activity: football, date: '2026-06-01', reason: 'sick');
      await db.markPlansPushed(
          await db.getDirtyPlans(), await db.getDirtyPlanLogs());
      await db.markAllForPush();
      expect((await db.getDirtyPlans()).length, 1);
      expect((await db.getDirtyPlanLogs()).length, 1);
    });
  });

  test('renaming a parent or kid renames them in visits and plans', () async {
    await db.saveFamily(['Mom', 'Dad'], ['Bean', 'Pip']);
    final both = await db.insertEntry(const Entry(
        date: '2026-06-01',
        shift: 'morning',
        user: 'Mom,Dad',
        vacation: false,
        kids: 'Bean,Pip'));
    final dadOnly = await db.insertEntry(const Entry(
        date: '2026-06-02',
        shift: 'morning',
        user: 'Dad',
        vacation: false,
        kids: 'Pip'));
    await db.upsertRecurringActivity(const RecurringActivity(
        id: 'swim', title: 'Swimming', kidNames: ['Bean'], repeatDays: [0]));
    await db.markEntriesPushed([
      (uuid: both.uuid, lastModified: both.lastModified),
      (uuid: dadOnly.uuid, lastModified: dadOnly.lastModified),
    ]);

    await db.saveFamily(['Mama', 'Dad'], ['Beanie', 'Pip'],
        renamedParents: {'Mom': 'Mama'}, renamedKids: {'Bean': 'Beanie'});

    final renamed = (await db.getEntryByUuid(both.uuid))!;
    expect(renamed.user, 'Mama,Dad');
    expect(renamed.kids, 'Beanie,Pip');
    expect((await db.getEntryByUuid(dadOnly.uuid))!.user, 'Dad');
    expect((await db.getAllRecurringActivities()).single.kidNames, ['Beanie']);
    // Only the visit that changed goes to iCloud again.
    expect((await db.getDirtyEntries()).map((e) => e.uuid), [both.uuid]);

    // The old visits count for the new name.
    final stats = await db.getDashboard(period: 'all');
    expect((stats['by_user'] as Map)['Mama'], 1);
    expect((stats['kids'] as Map)['Beanie'], 1);
  });

  test('reminder time labels follow the 24-hour setting', () async {
    const a = RecurringActivity(
      id: 'a1',
      title: 'Football',
      kidNames: [],
      repeatDays: [0],
      notifyHour: 15,
      notifyMinute: 5,
    );
    await AppSettings.instance.setUse24h(false);
    expect(a.notifyTimeLabel, '3:05 PM');
    await AppSettings.instance.setUse24h(true);
    expect(a.notifyTimeLabel, '15:05');
    await AppSettings.instance.setUse24h(false);
  });

  test('the theme choice is saved and every theme builds', () async {
    await AppSettings.instance.setPalette(AppPalette.swingDark);
    await AppSettings.instance.load();
    expect(AppSettings.instance.palette, AppPalette.swingDark);
    for (final p in AppPalette.values) {
      final colors = p.fixed ?? AppSettings.instance.customColors;
      final theme = buildTheme(colors);
      expect(theme.extension<AppColors>(), same(colors));
      expect(theme.brightness,
          colors.isDark ? Brightness.dark : Brightness.light);
    }
    await AppSettings.instance.setPalette(AppPalette.modernistLight);
  });

  test('an old palette plus appearance setting becomes one theme', () async {
    await db.setMeta('setting_palette', 'swing');
    await db.setMeta('setting_theme', 'dark');
    await AppSettings.instance.load();
    expect(AppSettings.instance.palette, AppPalette.swingDark);

    await db.setMeta('setting_palette', 'modernist');
    await db.setMeta('setting_theme', 'light');
    await AppSettings.instance.load();
    expect(AppSettings.instance.palette, AppPalette.modernistLight);
  });

  test('the language choice is saved; none follows the phone', () async {
    await AppSettings.instance.setLanguage('cs');
    await AppSettings.instance.load();
    expect(AppSettings.instance.language, 'cs');
    expect(AppSettings.instance.locale.languageCode, 'cs');
    expect(AppSettings.instance.isEnglish, isFalse);

    await AppSettings.instance.setLanguage(null);
    await AppSettings.instance.load();
    expect(AppSettings.instance.language, isNull);
    // The test platform speaks English.
    expect(AppSettings.instance.locale.languageCode, 'en');
  });

  test('My colors are saved and kept readable', () async {
    // A bright yellow accent on white is the hard case.
    await AppSettings.instance.setCustomColors(
        bg: const Color(0xFFFFFFFF),
        txt: const Color(0xFF000000),
        accent: const Color(0xFFFFEB3B));
    await AppSettings.instance.load();
    expect(AppSettings.instance.palette, AppPalette.custom);

    final c = AppSettings.instance.colors;
    expect(c.isDark, isFalse);
    expect(contrastRatio(c.txt2, c.bg), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(c.accentTxt, c.bg), greaterThanOrEqualTo(4.5));
    expect(c.onAccent, Colors.black); // black reads better on yellow
    await AppSettings.instance.setPalette(AppPalette.modernistLight);
  });

  test('Delete all data leaves an empty app with default settings', () async {
    // deleteAllData reaches the sync service's platform channel.
    TestWidgetsFlutterBinding.ensureInitialized();
    await db.saveFamily(['Mom'], ['Bean']);
    await db.insertEntry(entry());
    await AppSettings.instance.setPalette(AppPalette.swingDark);
    await AppSettings.instance.setGoal(const OutdoorGoal(GoalPeriod.week, 420));
    await AppSettings.instance.setExactTimes(true);

    expect(await deleteAllData(), isTrue);

    expect((await db.getFamily()).parents, isEmpty);
    expect(await db.getEntriesForDate('2026-06-01'), isEmpty);
    // Nothing chosen any more: the default follows the (light) test platform.
    expect(AppSettings.instance.palette, AppPalette.modernistLight);
    expect(AppSettings.instance.goal, isNull);
    expect(AppSettings.instance.exactTimes, isFalse);
  });

  test('the goal and the advanced-log choice are saved', () async {
    await AppSettings.instance.setGoal(const OutdoorGoal(GoalPeriod.year, 60000));
    await AppSettings.instance.setExactTimes(true);
    await AppSettings.instance.load();
    expect(AppSettings.instance.goal, const OutdoorGoal(GoalPeriod.year, 60000));
    expect(AppSettings.instance.exactTimes, isTrue);

    await AppSettings.instance.setGoal(null);
    await AppSettings.instance.setExactTimes(false);
    await AppSettings.instance.load();
    expect(AppSettings.instance.goal, isNull);
    expect(AppSettings.instance.exactTimes, isFalse);
  });

  test('a version 7 database upgrades and keeps its visits and plans',
      () async {
    final dir = Directory.systemTemp.createTempSync('playground_v7');
    final path = '${dir.path}/playground.db';
    final old = await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 7,
          onCreate: (d, _) async {
            // The entries table as version 7 created it.
            await d.execute('''
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
                needs_push    INTEGER DEFAULT 1,
                created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
              )
            ''');
            // And the plans table, as versions 5 to 8 had it.
            await d.execute('''
              CREATE TABLE recurring_activities (
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
          },
        ));
    await old.insert('recurring_activities',
        {'id': 'p1', 'title': 'Football', 'repeat_days': '[0]'});
    await old.insert('entries', {
      'uuid': 'old-1',
      'date': '2026-06-01',
      'shift': 'morning',
      'user': 'Mom',
      'duration': '1h',
      'last_modified': 5,
    });
    await old.close();

    await DatabaseHelper.resetForTests();
    DatabaseHelper.databasePathOverride = path;
    addTearDown(() async {
      await DatabaseHelper.resetForTests();
      DatabaseHelper.databasePathOverride = inMemoryDatabasePath;
      dir.deleteSync(recursive: true);
    });

    // Plans from before the switch were all logged as visits.
    final plans = await db.getAllRecurringActivities();
    expect(plans.single.outdoor, isTrue);
    // And they go to iCloud on the first sync after the update.
    expect((await db.getDirtyPlans()).single['id'], 'p1');

    final kept = await db.getEntryByUuid('old-1');
    expect(kept!.duration, '1h');
    expect(kept.hasTimes, isFalse);
    final timed = await db.insertEntry(const Entry(
        date: '2026-06-02',
        shift: 'evening',
        user: 'Mom',
        vacation: false,
        startTime: '16:00',
        endTime: '17:30'));
    expect(timed.startTime, '16:00');
  });

  test('exact start and end times are saved, synced in and cleared', () async {
    const timed = Entry(
      uuid: 't1',
      date: '2026-06-01',
      shift: 'evening',
      user: 'Mom',
      vacation: false,
      duration: '1h 25m',
      startTime: '15:10',
      endTime: '16:35',
      lastModified: 1000,
    );
    final saved = await db.insertEntry(timed);
    expect(saved.startTime, '15:10');
    expect(saved.endTime, '16:35');
    expect(saved.duration, '1h 25m');

    // Another device switched it back to a preset length.
    await db.mergeFromJson(remoteSnapshot(entries: [
      {...timed.toJsonMap(), 'duration': '1h', 'start_time': null,
        'end_time': null, 'last_modified': 2000},
    ]));
    final back = await db.getEntryByUuid('t1');
    expect(back!.hasTimes, isFalse);
    expect(back.duration, '1h');

    // And a new timed visit arrives from it.
    await db.mergeFromJson(remoteSnapshot(entries: [
      {...timed.toJsonMap(), 'uuid': 't2'},
    ]));
    expect((await db.getEntryByUuid('t2'))!.startTime, '15:10');
  });

  test('the log lists every entry newest day first, without deleted ones',
      () async {
    await db.insertEntry(entry(uuid: 'old', date: '2026-06-01'));
    await db.insertEntry(entry(uuid: 'new', date: '2026-06-03'));
    final gone = await db.insertEntry(entry(uuid: 'gone', date: '2026-06-02'));
    await db.deleteEntry(gone.id!);

    final all = await db.getAllEntries();
    expect(all.map((e) => e.uuid), ['new', 'old']);
  });
}
