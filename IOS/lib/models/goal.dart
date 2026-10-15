import 'dart:math';

import 'calendar_days.dart';
import 'durations.dart';
import 'entry.dart';

enum GoalPeriod { week, month, year }

/// The family's outdoor-time goal: so many hours a week, month or year.
class OutdoorGoal {
  final GoalPeriod period;
  final int minutes;
  const OutdoorGoal(this.period, this.minutes);

  /// Hours offered for each period in Settings › Outdoor goal.
  static const presetHours = {
    GoalPeriod.week: [3, 5, 7, 10, 14],
    GoalPeriod.month: [10, 20, 30, 45, 60],
    GoalPeriod.year: [100, 250, 500, 1000],
  };

  /// Picked when switching to a period.
  static const defaultHours = {
    GoalPeriod.week: 7,
    GoalPeriod.month: 30,
    GoalPeriod.year: 500,
  };

  /// From the two stored settings; null when unset, off or malformed.
  static OutdoorGoal? parse(String? period, String? minutes) {
    final p = GoalPeriod.values.where((v) => v.name == period).firstOrNull;
    final m = int.tryParse(minutes ?? '');
    if (p == null || m == null || m <= 0) return null;
    return OutdoorGoal(p, m);
  }

  /// First and last day of the period containing [day]. Weeks run Monday
  /// to Sunday, like the week strip on Today.
  (DateTime, DateTime) rangeFor(DateTime day) => switch (period) {
        GoalPeriod.week => (
            addDays(day, 1 - day.weekday),
            addDays(day, 7 - day.weekday)
          ),
        GoalPeriod.month => (
            DateTime(day.year, day.month, 1),
            DateTime(day.year, day.month + 1, 0)
          ),
        GoalPeriod.year => (DateTime(day.year, 1, 1), DateTime(day.year, 12, 31)),
      };

  @override
  bool operator ==(Object other) =>
      other is OutdoorGoal && other.period == period && other.minutes == minutes;

  @override
  int get hashCode => Object.hash(period, minutes);
}

class GoalProgress {
  /// Minutes outside so far in the period.
  final int done;
  final int target;

  /// Minutes behind an even pace through yesterday; 0 when on track.
  final int behind;

  /// Set when the log starts inside the period: [target] is then the
  /// goal's share from this day on.
  final DateTime? since;

  const GoalProgress(
      {required this.done,
      required this.target,
      required this.behind,
      this.since});

  bool get reached => done >= target;
  double get ratio => target <= 0 ? 0 : min(1, done / target);
}

/// Where the family stands on [goal] on [today]: the logged length of every
/// visit in the period. Pace only counts days already over, so Monday
/// morning is never "behind".
///
/// When the log starts inside the period (a new install, or a yearly goal
/// set in October with nothing logged before), it counts from the log's
/// first day against that share of the goal, instead of starting hundreds
/// of hours behind.
GoalProgress goalProgress(
    OutdoorGoal goal, Iterable<Entry> entries, DateTime today) {
  final (periodStart, end) = goal.rangeFor(today);
  final from = dayKey(periodStart), to = dayKey(end);
  var first = dayKey(today);
  var done = 0;
  for (final e in entries) {
    if (e.isDeleted) continue;
    if (e.date.compareTo(first) < 0) first = e.date;
    if (e.vacation || e.noPlayground) continue;
    if (e.date.compareTo(from) < 0 || e.date.compareTo(to) > 0) continue;
    done += durationMinutes(e.duration);
  }

  final firstDay = DateTime.parse(first);
  final partial = firstDay.isAfter(periodStart);
  final start = partial ? firstDay : periodStart;
  final days = daysBetween(start, end) + 1;
  final target = partial
      ? _roundTarget(goal.minutes * days / (daysBetween(periodStart, end) + 1))
      : goal.minutes;
  final pace = (target * daysBetween(start, today) / days).round();
  return GoalProgress(
      done: done,
      target: target,
      behind: max(0, pace - done),
      since: partial ? start : null);
}

/// A share of a goal, rounded the way people would set one: whole hours
/// from 10 hours up, else 5 minutes.
int _roundTarget(double minutes) => minutes >= 600
    ? (minutes / 60).round() * 60
    : max(5, (minutes / 5).round() * 5);
