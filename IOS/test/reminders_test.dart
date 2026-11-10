import 'package:flutter_test/flutter_test.dart';

import 'package:playground_tracker/models/recurring_activity.dart';
import 'package:playground_tracker/notifications/notification_service.dart';

void main() {
  // 2026-06-01 is a Monday.
  final mondayNoon = DateTime(2026, 6, 1, 12);

  RecurringActivity plan({String? from, String? to, List<int> days = const [0, 2]}) =>
      RecurringActivity(
        id: 'p',
        title: 'Football',
        kidNames: const [],
        repeatDays: days,
        dateFrom: from,
        dateTo: to,
        notifyEnabled: true,
        notifyHour: 16,
        notifyMinute: 30,
      );

  group('plan reminders', () {
    test('a plan without dates repeats weekly', () {
      expect(planReminderMoments(plan(), mondayNoon), isNull);
      // Started in the past, no end: also weekly.
      expect(planReminderMoments(plan(from: '2026-05-01'), mondayNoon), isNull);
    });

    test('a plan that starts later does not ring before its first day', () {
      final moments = planReminderMoments(plan(from: '2026-06-10'), mondayNoon)!;
      expect(moments.first, DateTime(2026, 6, 10, 16, 30)); // a Wednesday
      expect(moments.length, 8);
      expect(moments.every((m) => m.weekday == 1 || m.weekday == 3), isTrue);
    });

    test('a plan with a last day does not ring after it', () {
      final moments = planReminderMoments(plan(to: '2026-06-08'), mondayNoon)!;
      expect(moments, [
        DateTime(2026, 6, 1, 16, 30),
        DateTime(2026, 6, 3, 16, 30),
        DateTime(2026, 6, 8, 16, 30),
      ]);
    });

    test('today is left out once its time has passed', () {
      final evening = DateTime(2026, 6, 1, 18);
      final moments = planReminderMoments(plan(to: '2026-06-03'), evening)!;
      expect(moments, [DateTime(2026, 6, 3, 16, 30)]);
    });

    test('a one-time plan rings once, and never after its day', () {
      final party = plan(from: '2026-06-03', to: '2026-06-03', days: [2]);
      expect(planReminderMoments(party, mondayNoon),
          [DateTime(2026, 6, 3, 16, 30)]);
      expect(planReminderMoments(party, DateTime(2026, 6, 4)), isEmpty);
    });
  });

  group('daily reminders', () {
    test('a logged day gets no reminder that is still ahead', () {
      expect(skipTodaysReminder(mondayNoon, 15, 0, loggedToday: true), isTrue);
      expect(skipTodaysReminder(mondayNoon, 15, 0, loggedToday: false), isFalse);
      // Already rang today: the weekly repeat is next due in a week.
      expect(skipTodaysReminder(mondayNoon, 9, 0, loggedToday: true), isFalse);
    });
  });
}
