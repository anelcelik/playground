import 'package:flutter_test/flutter_test.dart';

import 'package:playground_tracker/models/entry.dart';
import 'package:playground_tracker/models/recurring_activity.dart';
import 'package:playground_tracker/services/calendar_service.dart';
import 'package:playground_tracker/services/recurring_service.dart';

void main() {
  group('Entry', () {
    test('generateUuid produces valid v4 UUIDs', () {
      final uuid = Entry.generateUuid();
      expect(
        uuid,
        matches(RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      );
      expect(Entry.generateUuid(), isNot(uuid));
    });

    test('copyWith preserves all fields including noPlayground', () {
      const original = Entry(
        uuid: 'u',
        date: '2026-06-01',
        shift: 'morning',
        user: 'Mom',
        vacation: false,
        noPlayground: true,
        excuse: 'rain',
        lastModified: 10,
      );
      final copy = original.copyWith(isDeleted: true, lastModified: 20);
      expect(copy.noPlayground, isTrue);
      expect(copy.excuse, 'rain');
      expect(copy.isDeleted, isTrue);
      expect(copy.lastModified, 20);
    });

    test('list getters split and trim comma fields', () {
      const e = Entry(
        date: '2026-06-01',
        shift: 'morning',
        user: 'Mom, Dad',
        vacation: false,
        kids: ' A , B ',
        activities: '',
      );
      expect(e.userList, ['Mom', 'Dad']);
      expect(e.kidList, ['A', 'B']);
      expect(e.activityList, isEmpty);
    });

    test('fromMap / toMap round-trip', () {
      const e = Entry(
        uuid: 'u',
        date: '2026-06-01',
        shift: 'evening',
        user: 'Dad',
        vacation: true,
        noPlayground: false,
        lastModified: 42,
        isDeleted: true,
      );
      final back = Entry.fromMap(e.toMap());
      expect(back.shift, 'evening');
      expect(back.vacation, isTrue);
      expect(back.isDeleted, isTrue);
      expect(back.lastModified, 42);
    });
  });

  group('RecurringActivity.appliesTo', () {
    RecurringActivity activity({
      List<int> days = const [0, 2], // Mon, Wed
      String? from,
      String? to,
      bool active = true,
    }) =>
        RecurringActivity(
          id: 'a1',
          title: 'Football',
          kidNames: const [],
          repeatDays: days,
          dateFrom: from,
          dateTo: to,
          isActive: active,
        );

    // 2026-06-01 is a Monday
    final monday = DateTime(2026, 6, 1);
    final tuesday = DateTime(2026, 6, 2);

    test('matches repeat day', () {
      expect(activity().appliesTo(monday), isTrue);
      expect(activity().appliesTo(tuesday), isFalse);
    });

    test('respects date range bounds inclusively', () {
      final a = activity(from: '2026-06-01', to: '2026-06-08');
      expect(a.appliesTo(monday), isTrue);
      expect(a.appliesTo(DateTime(2026, 6, 8)), isTrue); // Mon, last day
      expect(a.appliesTo(DateTime(2026, 6, 15)), isFalse); // Mon, after range
      expect(activity(from: '2026-06-02').appliesTo(monday), isFalse);
    });

    test('inactive never applies', () {
      expect(activity(active: false).appliesTo(monday), isFalse);
    });

    test('notifId stays in the reserved 100–9099 range', () {
      for (var day = 0; day < 7; day++) {
        final id = activity().notifId(day);
        expect(id, inInclusiveRange(100, 9099));
      }
    });
  });

  group('Entry.absentNote', () {
    Entry visit({String user = 'Mom', String? excuse}) => Entry(
        date: '2026-06-01',
        shift: 'morning',
        user: user,
        vacation: false,
        excuse: excuse);

    test('names the parent who stayed home', () {
      expect(visit(excuse: 'Work').absentNote(['Mom', 'Dad']),
          "Dad didn't go · Work");
    });

    test('empty without a reason, or for a nobody-went day', () {
      expect(visit().absentNote(['Mom', 'Dad']), '');
      const nobody = Entry(
          date: '2026-06-01',
          shift: 'morning',
          user: 'Mom,Dad',
          vacation: false,
          noPlayground: true,
          excuse: 'Rain');
      expect(nobody.absentNote(['Mom', 'Dad']), '');
    });
  });

  group('Plans', () {
    // 2026-06-01 is a Monday.
    const footballMonWed = RecurringActivity(
      id: 'f1',
      title: 'Football',
      kidNames: [],
      repeatDays: [0, 2],
      dateFrom: '2026-06-01',
    );
    RecurringLog log(String date, String status, [String? reason]) =>
        RecurringLog(
            id: date,
            activityId: 'f1',
            date: date,
            status: status,
            skipReason: reason);

    test('a one-time plan applies only on its date', () {
      const party = RecurringActivity(
        id: 'p1',
        title: 'Party',
        kidNames: [],
        repeatDays: [2], // Wednesday
        dateFrom: '2026-06-03',
        dateTo: '2026-06-03',
      );
      expect(party.isOneTime, isTrue);
      expect(footballMonWed.isOneTime, isFalse);
      expect(party.appliesTo(DateTime(2026, 6, 3)), isTrue);
      expect(party.appliesTo(DateTime(2026, 6, 10)), isFalse);
      expect(party.repeatDaysLabel, startsWith('Once · '));
    });

    test('history counts unopened past days as missed, newest first', () {
      final days = RecurringService.history(
        footballMonWed,
        [log('2026-06-01', 'confirmed'), log('2026-06-03', 'skipped', 'Rain')],
        DateTime(2026, 6, 10, 15), // Wednesday afternoon
      );
      expect(days.map((d) => '${d.date} ${d.status}').toList(), [
        '2026-06-10 pending',
        '2026-06-08 missed',
        '2026-06-03 skipped',
        '2026-06-01 confirmed',
      ]);
      expect(days[2].reason, 'Rain');
    });

    test('calendar starts on the next plan day at the plan time', () {
      // Tuesday → next is Wednesday; morning plan without a reminder → 09:00.
      expect(CalendarService.firstStart(footballMonWed, DateTime(2026, 6, 2, 15)),
          DateTime(2026, 6, 3, 9));
      final evening = footballMonWed.copyWith(
          shift: 'evening', notifyHour: 18, notifyMinute: 30);
      expect(CalendarService.firstStart(evening, DateTime(2026, 6, 2, 15)),
          DateTime(2026, 6, 3, 18, 30));
      const pastParty = RecurringActivity(
        id: 'p1',
        title: 'Party',
        kidNames: [],
        repeatDays: [2],
        dateFrom: '2026-06-03',
        dateTo: '2026-06-03',
      );
      expect(CalendarService.firstStart(pastParty, DateTime(2026, 6, 4)), isNull);
    });
  });
}
