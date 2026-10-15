import 'package:flutter_test/flutter_test.dart';

import 'package:playground_tracker/models/durations.dart';
import 'package:playground_tracker/models/entry.dart';
import 'package:playground_tracker/models/goal.dart';
import 'package:playground_tracker/models/streak.dart';

Entry visit(String date, {String? duration}) => Entry(
    date: date, shift: 'morning', user: 'Mom', vacation: false, duration: duration);
Entry vacation(String date) =>
    Entry(date: date, shift: 'morning', user: 'Mom', vacation: true);
Entry nobodyWent(String date) => Entry(
    date: date, shift: 'morning', user: 'Mom', vacation: false, noPlayground: true);

void main() {
  // 2026-10-15 is a Thursday.
  final thursday = DateTime(2026, 10, 15, 18, 30);

  group('current streak', () {
    test('counts visit days up to today', () {
      final s = currentStreak(
          [visit('2026-10-13'), visit('2026-10-14'), visit('2026-10-15')], thursday);
      expect(s.days, 3);
      expect(s.doneToday, isTrue);
      expect(s.atRisk, isFalse);
    });

    test('today is not over yet, so it is not a missed day', () {
      final s = currentStreak([visit('2026-10-13'), visit('2026-10-14')], thursday);
      expect(s.days, 2);
      expect(s.doneToday, isFalse);
      expect(s.atRisk, isFalse);
    });

    test('one missed day is forgiven and not counted', () {
      final s = currentStreak(
          [visit('2026-10-12'), visit('2026-10-14'), visit('2026-10-15')], thursday);
      expect(s.days, 3);
    });

    test('a logged "nobody went" day is a missed day like any other', () {
      final s = currentStreak([
        visit('2026-10-12'),
        nobodyWent('2026-10-13'),
        nobodyWent('2026-10-14'),
        visit('2026-10-15'),
      ], thursday);
      expect(s.days, 1);
    });

    test('two missed days in a row end it', () {
      final s = currentStreak(
          [visit('2026-10-11'), visit('2026-10-12'), visit('2026-10-15')], thursday);
      expect(s.days, 1);
    });

    test('missed yesterday: at risk until today is logged', () {
      final s = currentStreak([visit('2026-10-12'), visit('2026-10-13')], thursday);
      expect(s.days, 2);
      expect(s.atRisk, isTrue);
    });

    test('missed yesterday and the day before: over', () {
      final s = currentStreak([visit('2026-10-12')], thursday);
      expect(s.days, 0);
      expect(s.atRisk, isFalse);
    });

    test('vacation days pause it', () {
      final s = currentStreak([
        visit('2026-10-09'),
        vacation('2026-10-10'),
        vacation('2026-10-11'),
        vacation('2026-10-12'),
        vacation('2026-10-13'),
        vacation('2026-10-14'),
        visit('2026-10-15'),
      ], thursday);
      expect(s.days, 2);
    });

    test('deleted entries do not count', () {
      final gone = visit('2026-10-15').copyWith(isDeleted: true);
      expect(currentStreak([gone], thursday).days, 0);
    });

    test('works across a daylight-saving change', () {
      // Clocks go back in Europe on 2026-10-25.
      final s = currentStreak([
        for (var d = 20; d <= 31; d++) visit('2026-10-$d'),
      ], DateTime(2026, 10, 31, 12));
      expect(s.days, 12);
    });
  });

  test('longest streak uses the same rules', () {
    expect(longestStreak([]), 0);
    expect(
        longestStreak([
          visit('2026-10-01'),
          visit('2026-10-02'),
          visit('2026-10-04'), // the 3rd is forgiven
          visit('2026-10-05'),
          visit('2026-10-08'), // the 6th and 7th end it
        ]),
        4);
    // Several visits on one day are one day.
    expect(longestStreak([visit('2026-10-01'), visit('2026-10-01')]), 1);
  });

  group('goal', () {
    test('weeks run Monday to Sunday, months and years by the calendar', () {
      expect(const OutdoorGoal(GoalPeriod.week, 60).rangeFor(thursday),
          (DateTime(2026, 10, 12), DateTime(2026, 10, 18)));
      expect(const OutdoorGoal(GoalPeriod.month, 60).rangeFor(DateTime(2028, 2, 10)),
          (DateTime(2028, 2, 1), DateTime(2028, 2, 29)));
      expect(const OutdoorGoal(GoalPeriod.year, 60).rangeFor(thursday),
          (DateTime(2026, 1, 1), DateTime(2026, 12, 31)));
    });

    test('adds up this period’s visits, exact lengths included', () {
      final p = goalProgress(const OutdoorGoal(GoalPeriod.week, 7 * 60), [
        visit('2026-10-11', duration: '2h'), // last week
        visit('2026-10-12', duration: '1h'),
        visit('2026-10-13', duration: '1h 25m'),
        visit('2026-10-14'), // no length logged
        vacation('2026-10-15'),
      ], thursday);
      expect(p.done, 145);
      expect(p.target, 420);
      expect(p.left, 275);
      expect(p.reached, isFalse);
    });

    test('the target is the goal as set, whenever it was set', () {
      // 500h a year set on 15 Oct with nothing logged is still 500h.
      final p = goalProgress(
          const OutdoorGoal(GoalPeriod.year, 500 * 60), [], thursday);
      expect(p.target, 500 * 60);
      expect(p.left, 500 * 60);
      expect(p.ratio, 0);
    });

    test('reached caps the bar at full and nothing is left', () {
      final p = goalProgress(const OutdoorGoal(GoalPeriod.week, 60),
          [visit('2026-10-12', duration: '2h')], thursday);
      expect(p.reached, isTrue);
      expect(p.ratio, 1);
      expect(p.left, 0);
    });

    test('parses what Settings stores; off or broken is no goal', () {
      expect(OutdoorGoal.parse('year', '60000'),
          const OutdoorGoal(GoalPeriod.year, 60000));
      expect(OutdoorGoal.parse('', '0'), isNull);
      expect(OutdoorGoal.parse('week', 'x'), isNull);
      expect(OutdoorGoal.parse('fortnight', '60'), isNull);
    });
  });

  group('exact lengths', () {
    test('parse alongside the presets', () {
      expect(durationMinutes('1h 25m'), 85);
      expect(durationMinutes('40m'), 40);
      expect(durationMinutes('3h'), 180);
      expect(durationMinutes('1.5h'), 90);
      expect(durationMinutes('2+ hours'), 150);
      expect(durationMinutes(null), 0);
      expect(durationMinutes('soon'), 0);
    });

    test('format the way they are stored', () {
      expect(formatMinutes(85), '1h 25m');
      expect(formatMinutes(120), '2h');
      expect(formatMinutes(5), '5m');
      expect(durationMinutes(formatMinutes(605)), 605);
    });

    test('stay as they are, not snapped to a preset, when edited', () {
      expect(normalizeDuration('1h 25m'), '1h 25m');
      expect(normalizeDuration('1 hour'), '1h');
    });

    test('leaving the advanced log picks the nearest preset', () {
      expect(nearestPreset(85), '1.5h');
      expect(nearestPreset(20), '15m');
      expect(nearestPreset(400), '2h+');
      expect(nearestPreset(0), isNull);
    });

    test('clock times round-trip', () {
      expect(clockMinutes('15:10'), 910);
      expect(clockLabel(910), '15:10');
      expect(clockLabel(5), '00:05');
      expect(clockMinutes('25:00'), isNull);
      expect(clockMinutes(null), isNull);
    });
  });
}
