import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/durations.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../models/goal.dart';
import '../models/recurring_activity.dart';
import '../models/streak.dart';
import '../services/recurring_service.dart';
import '../settings/app_settings.dart';
import '../theme.dart';
import '../widgets/entry_actions.dart';
import '../widgets/modernist.dart';
import '../widgets/reason_sheet.dart';
import 'goal_screen.dart';
import 'quick_visit_sheet.dart';
import 'recap_screen.dart';
import '../l10n/l10n.dart';

/// Replaces the old EntryScreen as the first tab.
///
/// The old screen asked for date → who → shift → more options → morning
/// card → evening card → excuse card before Save: six decisions for
/// something that should happen daily in ten seconds. Here the default
/// path is one block that repeats the last visit, and everything else is
/// two taps. Same tables, same columns — fewer decisions.
///
/// Tapping a past day in the week strip (or the date, for older days)
/// shows that day instead, so a forgotten visit can still be logged.
class TodayScreen extends StatefulWidget {
  final Family family;
  final VoidCallback onEntrySaved;
  final VoidCallback onSeeHistory;

  const TodayScreen({
    super.key,
    required this.family,
    required this.onEntrySaved,
    required this.onSeeHistory,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  static String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  final _now = DateTime.now();
  late DateTime _day = DateUtils.dateOnly(_now);
  bool _loading = true;
  List<Entry> _entries = [];
  List<Entry> _lastVisit = [];
  // Every entry, for the streak and the goal.
  List<Entry> _all = [];
  List<RecurringActivityStatus> _recurring = [];
  // Weekday strip: date → number of parents who went that day.
  final Map<String, int> _week = {};

  String get _date => _fmt(_day);
  bool get _isToday => DateUtils.isSameDay(_day, _now);

  void _selectDay(DateTime d) {
    if (d.isAfter(_now) || DateUtils.isSameDay(d, _day)) return;
    setState(() => _day = DateUtils.dateOnly(d));
    _load();
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateUtils.dateOnly(_now),
    );
    if (picked != null) _selectDay(picked);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await DatabaseHelper.instance.getEntriesForDate(_date);
    final recurring = await RecurringService.instance.getStatusForDate(_date);
    final last = await DatabaseHelper.instance.getMostRecentVisitEntries();
    final all = await DatabaseHelper.instance.getAllEntries();

    // Seven small indexed queries beat one hand-rolled aggregate here.
    _week.clear();
    final monday = _day.subtract(Duration(days: _day.weekday - 1));
    for (var i = 0; i < 7; i++) {
      final d = _fmt(monday.add(Duration(days: i)));
      final dayEntries = await DatabaseHelper.instance.getEntriesForDate(d);
      if (dayEntries.any((e) => e.vacation)) {
        _week[d] = -1; // vacation
      } else {
        _week[d] = dayEntries
            .where((e) => !e.vacation && !e.noPlayground)
            .expand((e) => e.userList)
            .toSet()
            .length;
      }
    }

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _recurring = recurring;
      _lastVisit = last;
      _all = all;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
    widget.onEntrySaved();
  }

  Entry? _entryFor(String shift) {
    for (final e in _entries) {
      if (e.shift == shift && !e.vacation && !e.noPlayground) return e;
    }
    return null;
  }

  bool get _hasVisit => _entries.any((e) => !e.vacation && !e.noPlayground);
  bool get _isVacation => _entries.any((e) => e.vacation);
  bool get _isNoPlayground => _entries.any((e) => e.noPlayground);

  /// One tap: re-log the most recent visit as-is against today.
  Future<void> _repeatLast() async {
    final source = _lastVisit.first;
    await DatabaseHelper.instance.insertEntry(Entry(
      date: _date,
      shift: source.shift,
      user: source.user,
      vacation: false,
      duration: source.duration,
      kids: source.kids,
      activities: source.activities,
      startTime: source.startTime,
      endTime: source.endTime,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.l10n.visitLogged),
      // With an action, Flutter would otherwise keep it up until tapped.
      persist: false,
      action: SnackBarAction(
        label: context.l10n.edit.toUpperCase(),
        onPressed: () => _openSheet(source.shift),
      ),
    ));
  }

  Future<void> _openSheet(String shift) async {
    final saved = await showQuickVisitSheet(
      context,
      family: widget.family,
      date: _date,
      shift: shift,
      existing: _entryFor(shift),
      prefill: _lastVisit.where((e) => e.shift == shift).firstOrNull ??
          _lastVisit.firstOrNull,
    );
    if (saved == true) await _refresh();
  }

  /// Nobody went / on vacation — both write a single flag Entry for the day.
  Future<void> _logNonVisit({required bool vacation}) async {
    String? reason;
    if (!vacation) {
      reason = await showReasonSheet(context);
      if (reason == null) return;
    }
    await DatabaseHelper.instance.insertEntry(Entry(
      date: _date,
      shift: 'morning',
      user: widget.family.parents.join(','),
      vacation: vacation,
      noPlayground: !vacation,
      excuse: reason,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    ));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (_loading) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _load,
      color: c.green,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(c),
          _weekStrip(c),
          if (_isToday) _progressBand(c),
          if (_isVacation || _isNoPlayground)
            _nonVisitNotice(c)
          else
            _logSection(c),
          if (_recurring.isNotEmpty) ...[
            const Rule(),
            _plannedSection(c),
          ],
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────

  Widget _header(AppColors c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tap the date to reach a day before this week.
                  InkWell(
                    onTap: _pickDay,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppSettings.instance.fmtDateFull(_date).toUpperCase(),
                            style: AppType.label
                                .copyWith(color: c.txt2, letterSpacing: 1.6)),
                        const SizedBox(width: 6),
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: c.txt2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(_dayTitle,
                      style: AppType.title.copyWith(color: c.txt)),
                ],
              ),
            ),
            if (!_isToday)
              TextButton(
                onPressed: () => _selectDay(_now),
                child: Text(context.l10n.today.toUpperCase(),
                    style: AppType.label
                        .copyWith(color: c.accentTxt, fontSize: 11)),
              ),
            // Recap used to be buried in the gear popup.
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RecapScreen())),
              child: Text(context.l10n.recap.toUpperCase(),
                  style: AppType.label
                      .copyWith(color: c.accentTxt, fontSize: 11)),
            ),
          ],
        ),
      );

  String get _dayTitle {
    if (_isToday) return context.l10n.today;
    if (DateUtils.isSameDay(_day, _now.subtract(const Duration(days: 1)))) {
      return context.l10n.yesterday;
    }
    return toBeginningOfSentenceCase(DateFormat('EEEE').format(_day));
  }

  // ── Week strip ──────────────────────────────────────────

  /// The week of the shown day. Past days are tappable; future ones are
  /// dimmed, since there is nothing to log for them yet.
  Widget _weekStrip(AppColors c) {
    final monday = _day.subtract(Duration(days: _day.weekday - 1));
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: c.border, width: 2),
          bottom: BorderSide(color: c.border, width: 2),
        ),
      ),
      child: Row(
        children: List.generate(7, (i) {
          final d = monday.add(Duration(days: i));
          final key = _fmt(d);
          final selected = key == _date;
          final future = d.isAfter(_now);
          final count = _week[key] ?? 0;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: future ? null : () => _selectDay(d),
              child: Opacity(
                opacity: future ? 0.35 : 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? c.txt : Colors.transparent,
                    border: Border(
                      right: i < 6
                          ? BorderSide(color: c.hairline, width: 1)
                          : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(DateFormat('EEEEE').format(d).toUpperCase(),
                          style: AppType.label.copyWith(
                              fontSize: 9,
                              letterSpacing: 1,
                              color: selected
                                  ? c.bg.withValues(alpha: 0.75)
                                  : c.txt2)),
                      const SizedBox(height: 3),
                      Text('${d.day}',
                          style: AppType.body.copyWith(
                              fontSize: 15,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected ? c.bg : c.txt)),
                      const SizedBox(height: 5),
                      _dayMark(c, count, selected),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _dayMark(AppColors c, int count, bool isToday) {
    // -1 vacation · 0 nothing logged · 1 one parent · 2+ both
    if (count == -1) {
      // An outline, not a fill: with the accent as ink it read as "both".
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          border: Border.all(color: isToday ? c.bg : c.txt, width: 2),
        ),
      );
    }
    if (count == 0) {
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          border: Border.all(
              color: isToday ? c.bg.withValues(alpha: 0.5) : c.hairline,
              width: 1.5),
        ),
      );
    }
    return Container(
        width: 7, height: 7, color: count >= 2 ? c.green : c.accentLt);
  }

  // ── Streak & goal ───────────────────────────────────────

  /// Today only, under the week strip: the running streak and how this
  /// week's (month's, year's) goal is going.
  Widget _progressBand(AppColors c) => Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.border, width: 2)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 4, child: _streakCell(c, currentStreak(_all, _now))),
              Container(width: 1, color: c.hairline),
              Expanded(flex: 5, child: _goalCell(c, AppSettings.instance.goal)),
            ],
          ),
        ),
      );

  /// Tap explains the rule, since a forgiven day can look like a bug.
  Widget _streakCell(AppColors c, Streak s) {
    final l = context.l10n;
    final status = s.doneToday
        ? l.streakDoneToday
        : s.days == 0
            ? l.streakStart
            : s.atRisk
                ? l.streakAtRisk
                : l.streakKeepGoing;
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.streakRule))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${s.days}',
                    style: AppType.title.copyWith(fontSize: 26, color: c.txt)),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(l.streakDays(s.days).toUpperCase(),
                      style: AppType.label.copyWith(color: c.txt2)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(status,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppType.bodySm.copyWith(
                    fontWeight: s.atRisk ? FontWeight.w700 : FontWeight.w500,
                    color: s.atRisk ? c.accentTxt : c.txt2)),
          ],
        ),
      ),
    );
  }

  Widget _goalCell(AppColors c, OutdoorGoal? goal) {
    final l = context.l10n;
    Future<void> open() async {
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => const GoalScreen()));
      if (mounted) setState(() {});
    }

    if (goal == null) {
      return InkWell(
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l.goal.toUpperCase(),
                  style: AppType.label.copyWith(color: c.txt2)),
              const SizedBox(height: 6),
              Text(l.setAGoal,
                  style: AppType.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.accentTxt,
                      decoration: TextDecoration.underline,
                      decorationColor: c.accentTxt)),
            ],
          ),
        ),
      );
    }

    final p = goalProgress(goal, _all, _now);
    final title = switch (goal.period) {
      GoalPeriod.week => l.thisWeek,
      GoalPeriod.month => l.thisMonth,
      GoalPeriod.year => l.thisYear,
    };
    final status = p.reached
        ? l.goalReached
        : p.behind > 0
            ? l.goalBehind(formatMinutes(p.behind))
            : l.goalOnTrack;
    return InkWell(
      onTap: open,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title.toUpperCase(),
                      style: AppType.label.copyWith(color: c.txt2)),
                ),
                Text('${(p.ratio * 100).floor()}%',
                    style: AppType.label.copyWith(color: c.txt2)),
              ],
            ),
            const SizedBox(height: 4),
            Text(l.goalOf(formatMinutes(p.done), formatMinutes(p.target)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.body.copyWith(
                    fontSize: 15, fontWeight: FontWeight.w800, color: c.txt)),
            const SizedBox(height: 6),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: c.recessed,
                  border: Border.all(color: c.hairline, width: 1)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: p.ratio,
                child: Container(color: c.green),
              ),
            ),
            const SizedBox(height: 5),
            Text(status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.bodySm.copyWith(
                    fontWeight: p.reached ? FontWeight.w700 : FontWeight.w500,
                    color: p.reached ? c.accentTxt : c.txt2)),
          ],
        ),
      ),
    );
  }

  // ── Log section ─────────────────────────────────────────

  Widget _logSection(AppColors c) {
    final morning = _entryFor('morning');
    final evening = _entryFor('evening');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
            _hasVisit ? context.l10n.addAnother : context.l10n.logAVisit),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The one-tap path. Hidden until there is a visit to repeat,
              // so a brand-new install never sees an empty promise.
              if (_lastVisit.isNotEmpty && !_hasVisit) ...[
                BlockButton(
                  label: context.l10n.sameAsUsual,
                  sublabel: _describe(_lastVisit.first),
                  icon: Icons.arrow_forward,
                  onTap: _repeatLast,
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                      child: _shiftBlock(c, 'morning', context.l10n.morning, morning)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _shiftBlock(c, 'evening', context.l10n.evening, evening)),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  _textAction(
                      c,
                      _isToday
                          ? context.l10n.nobodyWentToday
                          : context.l10n.nobodyWent,
                      accent: true,
                      onTap: () => _logNonVisit(vacation: false)),
                  const SizedBox(width: 16),
                  _textAction(c, context.l10n.onVacation,
                      onTap: () => _logNonVisit(vacation: true)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shiftBlock(AppColors c, String shift, String label, Entry? entry) {
    final logged = entry != null;
    // Tap edits the visit; a long press offers Edit / Delete (the day's full
    // list lives in Settings › Log now).
    return GestureDetector(
      onLongPress: logged
          ? () => showEntryActions(context,
              entry: entry, family: widget.family, onChanged: _refresh)
          : null,
      child: Block(
        onTap: () => _openSheet(shift),
        recessed: logged,
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label.toUpperCase(),
                      style: AppType.label.copyWith(
                          fontSize: 13, letterSpacing: 0.5, color: c.txt)),
                ),
                if (logged) Icon(Icons.check, size: 15, color: c.accentTxt),
              ],
            ),
            const SizedBox(height: 2),
            Text(
                logged
                    ? _describe(entry, withShift: false)
                    : context.l10n.notLogged,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.bodySm.copyWith(color: c.txt2)),
          ],
        ),
      ),
    );
  }

  Widget _textAction(AppColors c, String label,
          {bool accent = false, VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label,
              style: AppType.bodySm.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent ? c.accentTxt : c.txt2,
                  decoration: TextDecoration.underline,
                  decorationColor: accent ? c.accentTxt : c.txt2)),
        ),
      );

  String _describe(Entry e, {bool withShift = true}) {
    final parts = <String>[
      if (withShift)
        e.shift == 'morning' ? context.l10n.morning : context.l10n.evening,
      if (e.userList.isNotEmpty) e.userList.join(' & '),
      if (e.kidList.isNotEmpty) e.kidList.join(' & '),
      if (e.hasTimes)
        AppSettings.instance.fmtClockRange(e.startTime!, e.endTime!)
      else if (e.duration != null && e.duration!.isNotEmpty)
        e.duration!,
    ];
    return parts.join(' · ');
  }

  // ── Vacation / nobody-went notice ───────────────────────

  Widget _nonVisitNotice(AppColors c) {
    final entry = _entries.firstWhere((e) => e.vacation || e.noPlayground);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Block(
        recessed: true,
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        onTap: () => showEntryActions(context,
            entry: entry, family: widget.family, onChanged: _refresh),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      (entry.vacation
                              ? context.l10n.onVacation
                              : context.l10n.nobodyWent)
                          .toUpperCase(),
                      style: AppType.label
                          .copyWith(fontSize: 13, color: c.txt)),
                  const SizedBox(height: 3),
                  Text(
                      entry.excuse?.isNotEmpty == true
                          ? context.l10n.reasonTapToChange(
                              reasonsLabel(context.l10n, entry.excuse!))
                          : context.l10n.tapToChange,
                      style: AppType.bodySm.copyWith(color: c.txt2)),
                ],
              ),
            ),
            Icon(Icons.more_horiz, size: 20, color: c.txt2),
          ],
        ),
      ),
    );
  }

  // ── Planned (recurring) ─────────────────────────────────

  Widget _plannedSection(AppColors c) {
    final done = _recurring.where((r) => r.isConfirmed).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
            _isToday ? context.l10n.plannedForToday : context.l10n.planned,
            trailing: context.l10n.doneOfTotal(done, _recurring.length)),
        for (final r in _recurring)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _plannedRow(c, r),
          ),
      ],
    );
  }

  Widget _plannedRow(AppColors c, RecurringActivityStatus r) {
    final a = r.activity;
    // A past day auto-marks untouched plans as missed; keep DONE / SKIP
    // available so they can still be filled in afterwards.
    final resolved = !r.isPending && !r.isMissed;
    final subtitle = [
      if (a.notifyTimeLabel.isNotEmpty) a.notifyTimeLabel,
      if (a.kidNames.isNotEmpty) a.kidNames.join(' & '),
    ].join(' · ');

    if (resolved) {
      // A plan that isn't time outside logs no visit, so there is nothing
      // to edit.
      final statusText = r.isConfirmed
          ? (r.entry == null
              ? context.l10n.done
              : context.l10n.confirmedTapToEdit)
          : r.isSkipped
              ? (r.log?.skipReason != null
                  ? context.l10n.skippedBecause(
                      reasonLabel(context.l10n, r.log!.skipReason!))
                  : context.l10n.skipped)
              : context.l10n.missed;
      return Block(
        recessed: true,
        onTap: r.entry == null
            ? null
            : () => showEntryActions(context,
                entry: r.entry!, family: widget.family, onChanged: _refresh),
        child: Row(
          children: [
            Icon(r.isConfirmed ? Icons.check : Icons.remove,
                size: 15, color: c.txt2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title.toUpperCase(),
                      style: AppType.label.copyWith(
                          fontSize: 14,
                          letterSpacing: 0.4,
                          color: c.txt2,
                          decoration: r.isConfirmed
                              ? null
                              : TextDecoration.lineThrough)),
                  const SizedBox(height: 2),
                  Text(statusText,
                      style: AppType.bodySm.copyWith(color: c.txt2)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Block(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title.toUpperCase(),
                    style: AppType.label.copyWith(
                        fontSize: 14, letterSpacing: 0.4, color: c.txt)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppType.bodySm.copyWith(color: c.txt2)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          _pill(c, context.l10n.done.toUpperCase(), filled: true, onTap: () async {
            await RecurringService.instance.confirm(
                activity: a, date: _date, family: widget.family);
            await _refresh();
          }),
          const SizedBox(width: 6),
          _pill(c, context.l10n.skip.toUpperCase(), onTap: () async {
            final reason = await showReasonSheet(context,
                title: context.l10n.whySkip,
                hint: context.l10n.whySkipHint(a.title));
            if (reason == null) return;
            await RecurringService.instance
                .skip(activity: a, date: _date, reason: reason);
            await _refresh();
          }),
        ],
      ),
    );
  }

  Widget _pill(AppColors c, String label,
          {bool filled = false, VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 52),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: filled ? c.txt : Colors.transparent,
            border: filled ? null : Border.all(color: c.hairline, width: 2),
          ),
          child: Text(label,
              style: AppType.label.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: filled ? c.bg : c.txt2)),
        ),
      );
}
