import 'calendar_days.dart';
import 'entry.dart';

// A streak counts days with at least one visit. One missed day is forgiven;
// two missed days in a row end it. Vacation days pause it: they neither
// count nor break it. Today is never a missed day, since it isn't over.

class Streak {
  final int days;
  final bool doneToday;

  /// Yesterday was missed, so missing today too would end the streak.
  final bool atRisk;

  const Streak(
      {required this.days, required this.doneToday, required this.atRisk});
}

({Set<String> visits, Set<String> vacations}) _dayKinds(
    Iterable<Entry> entries) {
  final visits = <String>{}, vacations = <String>{};
  for (final e in entries) {
    if (e.isDeleted) continue;
    if (e.vacation) {
      vacations.add(e.date);
    } else if (!e.noPlayground) {
      visits.add(e.date);
    }
  }
  return (visits: visits, vacations: vacations);
}

/// The streak running on [today].
Streak currentStreak(Iterable<Entry> entries, DateTime today) {
  final k = _dayKinds(entries);
  final doneToday = k.visits.contains(dayKey(today));
  if (k.visits.isEmpty) {
    return const Streak(days: 0, doneToday: false, atRisk: false);
  }
  final first = k.visits.reduce((a, b) => a.compareTo(b) <= 0 ? a : b);

  var days = 0, misses = 0, missesSinceLastVisit = 0;
  var seenVisit = false;
  var d = addDays(today, doneToday ? 0 : -1);
  while (dayKey(d).compareTo(first) >= 0) {
    final key = dayKey(d);
    if (k.visits.contains(key)) {
      days++;
      misses = 0;
      seenVisit = true;
    } else if (!k.vacations.contains(key)) {
      if (++misses >= 2) break;
      if (!seenVisit) missesSinceLastVisit++;
    }
    d = addDays(d, -1);
  }
  return Streak(
    days: days,
    doneToday: doneToday,
    atRisk: !doneToday && days > 0 && missesSinceLastVisit == 1,
  );
}

/// The longest streak anywhere in [entries].
int longestStreak(Iterable<Entry> entries) {
  final k = _dayKinds(entries);
  if (k.visits.isEmpty) return 0;
  final sorted = k.visits.toList()..sort();
  final last = sorted.last;

  var run = 0, best = 0, misses = 0;
  for (var d = DateTime.parse(sorted.first);
      dayKey(d).compareTo(last) <= 0;
      d = addDays(d, 1)) {
    final key = dayKey(d);
    if (k.visits.contains(key)) {
      run++;
      misses = 0;
      if (run > best) best = run;
    } else if (!k.vacations.contains(key)) {
      if (++misses >= 2) run = 0;
    }
  }
  return best;
}
