import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../models/recurring_activity.dart';
import '../services/recurring_service.dart';
import '../settings/app_settings.dart';
import '../theme.dart';
import '../widgets/entry_actions.dart';
import '../widgets/modernist.dart';
import 'quick_visit_sheet.dart';
import 'recap_screen.dart';

/// Replaces the old EntryScreen as the first tab.
///
/// The old screen asked for date → who → shift → more options → morning
/// card → evening card → excuse card before Save: six decisions for
/// something that should happen daily in ten seconds. Here the default
/// path is one block that repeats the last visit, and everything else is
/// two taps. Same tables, same columns — fewer decisions.
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

  final _today = DateTime.now();
  bool _loading = true;
  List<Entry> _entries = [];
  List<Entry> _lastVisit = [];
  List<RecurringActivityStatus> _recurring = [];
  // Weekday strip: date → number of parents who went that day.
  final Map<String, int> _week = {};

  String get _date => _fmt(_today);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await DatabaseHelper.instance.getEntriesForDate(_date);
    final recurring = await RecurringService.instance.getStatusForDate(_date);
    final last = await DatabaseHelper.instance.getMostRecentVisitEntries();

    // Seven small indexed queries beat one hand-rolled aggregate here.
    _week.clear();
    final monday = _today.subtract(Duration(days: _today.weekday - 1));
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
      lastModified: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Visit logged'),
      action: SnackBarAction(
        label: 'EDIT',
        textColor: Colors.white,
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
      reason = await _askReason();
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

  Future<String?> _askReason() async {
    final tags = await DatabaseHelper.instance.getTags('excuse');
    if (!mounted) return null;
    return showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Rule(),
              const SectionLabel('Why not?'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in (tags.isEmpty
                        ? const ['Rain', 'Sick', 'Too late', 'Busy']
                        : tags))
                      SquareChip(
                          label: t,
                          onTap: () => Navigator.pop(ctx, t)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text('Tap a reason to save the day as “nobody went”.',
                    style: AppType.bodySm.copyWith(color: c.txt2)),
              ),
            ],
          ),
        );
      },
    );
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
          if (_isVacation || _isNoPlayground)
            _nonVisitNotice(c)
          else
            _logSection(c),
          if (_recurring.isNotEmpty) ...[
            const Rule(),
            _plannedSection(c),
          ],
          if (_entries.isNotEmpty) ...[
            const Rule(),
            _logList(c),
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
                  Text(AppSettings.instance.fmtDateFull(_date).toUpperCase(),
                      style: AppType.label
                          .copyWith(color: c.txt2, letterSpacing: 1.6)),
                  const SizedBox(height: 5),
                  Text('Today',
                      style: AppType.title.copyWith(color: c.txt)),
                ],
              ),
            ),
            // Recap used to be buried in the gear popup.
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RecapScreen())),
              child: Text('RECAP',
                  style: AppType.label
                      .copyWith(color: c.accentTxt, fontSize: 11)),
            ),
          ],
        ),
      );

  // ── Week strip ──────────────────────────────────────────

  Widget _weekStrip(AppColors c) {
    final monday = _today.subtract(Duration(days: _today.weekday - 1));
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
          final isToday = key == _date;
          final count = _week[key] ?? 0;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? c.txt : Colors.transparent,
                border: Border(
                  right: i < 6
                      ? BorderSide(color: c.hairline, width: 1)
                      : BorderSide.none,
                ),
              ),
              child: Column(
                children: [
                  Text(DateFormat('E').format(d)[0],
                      style: AppType.label.copyWith(
                          fontSize: 9,
                          letterSpacing: 1,
                          color: isToday
                              ? c.bg.withValues(alpha: 0.75)
                              : c.txt2)),
                  const SizedBox(height: 3),
                  Text('${d.day}',
                      style: AppType.body.copyWith(
                          fontSize: 15,
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w600,
                          color: isToday ? c.bg : c.txt)),
                  const SizedBox(height: 5),
                  _dayMark(c, count, isToday),
                ],
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
      return Container(width: 7, height: 7, color: isToday ? c.bg : c.txt);
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

  // ── Log section ─────────────────────────────────────────

  Widget _logSection(AppColors c) {
    final morning = _entryFor('morning');
    final evening = _entryFor('evening');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(_hasVisit ? 'Add another' : 'Log a visit'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The one-tap path. Hidden until there is a visit to repeat,
              // so a brand-new install never sees an empty promise.
              if (_lastVisit.isNotEmpty && !_hasVisit) ...[
                BlockButton(
                  label: 'Same as usual',
                  sublabel: _describe(_lastVisit.first),
                  icon: Icons.arrow_forward,
                  onTap: _repeatLast,
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                      child: _shiftBlock(c, 'morning', 'Morning', morning)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _shiftBlock(c, 'evening', 'Evening', evening)),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  _textAction(c, 'Nobody went today',
                      accent: true,
                      onTap: () => _logNonVisit(vacation: false)),
                  const SizedBox(width: 16),
                  _textAction(c, 'On vacation',
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
    return Block(
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
          Text(logged ? _describe(entry) : 'Not logged',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.bodySm.copyWith(color: c.txt2)),
        ],
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

  String _describe(Entry e) {
    final parts = <String>[
      e.shift == 'morning' ? 'Morning' : 'Evening',
      if (e.userList.isNotEmpty) e.userList.join(' & '),
      if (e.kidList.isNotEmpty) e.kidList.join(' & '),
      if (e.duration != null && e.duration!.isNotEmpty) e.duration!,
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
                  Text(entry.vacation ? 'ON VACATION' : 'NOBODY WENT',
                      style: AppType.label
                          .copyWith(fontSize: 13, color: c.txt)),
                  const SizedBox(height: 3),
                  Text(
                      entry.excuse?.isNotEmpty == true
                          ? '${entry.excuse} · tap to change'
                          : 'Tap to change',
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
        SectionLabel('Planned for today',
            trailing: '$done of ${_recurring.length} done'),
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
    final resolved = !r.isPending;
    final subtitle = [
      if (a.notifyTimeLabel.isNotEmpty) a.notifyTimeLabel,
      if (a.kidNames.isNotEmpty) a.kidNames.join(' & '),
    ].join(' · ');

    if (resolved) {
      final statusText = r.isConfirmed
          ? 'Confirmed · tap to edit'
          : r.isSkipped
              ? 'Skipped${r.log?.skipReason != null ? ' · ${r.log!.skipReason}' : ''}'
              : 'Missed';
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
          _pill(c, 'DONE', filled: true, onTap: () async {
            await RecurringService.instance.confirm(
                activity: a, date: _date, family: widget.family);
            await _refresh();
          }),
          const SizedBox(width: 6),
          _pill(c, 'SKIP', onTap: () async {
            await RecurringService.instance
                .skip(activity: a, date: _date, reason: 'other');
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

  // ── Today's log ─────────────────────────────────────────

  Widget _logList(AppColors c) {
    final visits = _entries.where((e) => !e.vacation && !e.noPlayground).toList();
    if (visits.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel("Today's log"),
        for (final e in visits)
          InkWell(
            onTap: () => showEntryActions(context,
                entry: e, family: widget.family, onChanged: _refresh),
            child: Column(
              children: [
                const Hairline(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                            (e.shift == 'morning' ? 'Morning' : 'Evening')
                                .toUpperCase(),
                            style: AppType.label.copyWith(
                                color: c.accentTxt, letterSpacing: 1.1)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                [
                                  e.userList.join(' & '),
                                  if (e.kidList.isNotEmpty)
                                    e.kidList.join(' & ')
                                ].join(' · '),
                                style: AppType.body.copyWith(
                                    fontWeight: FontWeight.w700, color: c.txt)),
                            if (e.duration?.isNotEmpty == true ||
                                e.activityList.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                  [
                                    if (e.duration?.isNotEmpty == true)
                                      e.duration!,
                                    if (e.activityList.isNotEmpty)
                                      e.activityList.join(', ')
                                  ].join(' · '),
                                  style:
                                      AppType.bodySm.copyWith(color: c.txt2)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const Hairline(),
      ],
    );
  }
}
