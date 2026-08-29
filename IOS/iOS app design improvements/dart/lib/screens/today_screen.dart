import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../models/recurring_activity.dart';
import '../services/recurring_service.dart';
import '../settings/app_settings.dart';
import '../sync/sync_controller.dart';
import '../sync/sync_service.dart';
import '../theme.dart';
import '../widgets/entry_actions.dart';
import '../widgets/recurring_activity_card.dart';
import '../widgets/visit_sheet.dart';
import 'edit_entry_screen.dart';

/// The fast path. Two taps to log a normal day, one for a repeat day.
///
/// Everything the old EntryScreen asked for up front (who / when / how long /
/// which kids / activities / excuse) now lives in [VisitSheet], prefilled from
/// the last visit of the same shift. Same tables, same columns — fewer
/// decisions before Save.
class TodayScreen extends StatefulWidget {
  final Family family;
  const TodayScreen({super.key, required this.family});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DateTime _date = DateTime.now();
  List<Entry> _dayEntries = [];
  List<RecurringActivityStatus> _recurring = [];
  List<Entry> _lastVisit = [];
  Map<String, int> _weekCounts = {}; // yyyy-MM-dd -> visits that day
  Map<String, bool> _weekVacation = {};

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool get _isToday {
    final n = DateTime.now();
    return _date.year == n.year && _date.month == n.month && _date.day == n.day;
  }

  bool get _isFuture {
    final n = DateTime.now();
    return DateTime(_date.year, _date.month, _date.day)
        .isAfter(DateTime(n.year, n.month, n.day));
  }

  @override
  void initState() {
    super.initState();
    _load();
    AppSettings.instance.addListener(_onSettings);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettings);
    super.dispose();
  }

  void _onSettings() => setState(() {});

  Future<void> _load() async {
    final date = _fmt(_date);
    final entries = await DatabaseHelper.instance.getEntriesForDate(date);
    final recurring = await RecurringService.instance.getStatusForDate(date);
    final last = await DatabaseHelper.instance.getMostRecentVisitEntries();

    // Week strip — Monday-first week containing the selected date.
    final monday = _date.subtract(Duration(days: _date.weekday - 1));
    final counts = <String, int>{};
    final vac = <String, bool>{};
    for (var i = 0; i < 7; i++) {
      final key = _fmt(monday.add(Duration(days: i)));
      final e = await DatabaseHelper.instance.getEntriesForDate(key);
      counts[key] = e.where((x) => !x.vacation && !x.noPlayground).length;
      vac[key] = e.any((x) => x.vacation);
    }

    if (!mounted) return;
    setState(() {
      _dayEntries = entries;
      _recurring = recurring;
      _lastVisit = last;
      _weekCounts = counts;
      _weekVacation = vac;
    });
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  // ── Actions ─────────────────────────────────────────────

  /// One tap: repeat the most recent visit onto the selected date.
  Future<void> _sameAsUsual() async {
    if (_lastVisit.isEmpty) {
      _toast('No previous visit to copy yet');
      return;
    }
    final date = _fmt(_date);
    for (final e in _lastVisit) {
      final saved = await DatabaseHelper.instance.insertEntry(Entry(
        date: date,
        shift: e.shift,
        user: e.user,
        vacation: false,
        duration: e.duration,
        kids: e.kids,
        activities: e.activities,
      ));
      SyncService.instance.pushEntry(saved);
    }
    _toast('Logged — same as usual');
    await _load();
    SyncService.instance.sync();
  }

  Future<void> _openSheet(String shift) async {
    final saved = await showVisitSheet(
      context,
      family: widget.family,
      date: _fmt(_date),
      shift: shift,
    );
    if (saved == true) {
      await _load();
      SyncService.instance.sync();
    }
  }

  Future<void> _logNobodyWent() async {
    final reason = await showReasonSheet(context, title: 'Why not?');
    if (reason == null) return;
    final saved = await DatabaseHelper.instance.insertEntry(Entry(
      date: _fmt(_date),
      shift: 'morning',
      user: widget.family.parents.join(','),
      vacation: false,
      noPlayground: true,
      excuse: reason.isEmpty ? null : reason,
    ));
    SyncService.instance.pushEntry(saved);
    await _load();
    SyncService.instance.sync();
  }

  Future<void> _logVacation() async {
    final saved = await DatabaseHelper.instance.insertEntry(Entry(
      date: _fmt(_date),
      shift: 'morning',
      user: widget.family.parents.join(','),
      vacation: true,
    ));
    SyncService.instance.pushEntry(saved);
    await _load();
    SyncService.instance.sync();
  }

  Future<void> _confirmRecurring(RecurringActivityStatus s) async {
    final result = await RecurringService.instance
        .confirm(activity: s.activity, date: _fmt(_date), family: widget.family);
    if (!mounted) return;
    setState(() {
      final i = _recurring.indexWhere((r) => r.activity.id == s.activity.id);
      if (i >= 0) _recurring[i] = result;
    });
    _load();
  }

  Future<void> _skipRecurring(RecurringActivityStatus s) async {
    final reason = await showSkipSheet(context);
    if (reason == null || !mounted) return;
    final result = await RecurringService.instance
        .skip(activity: s.activity, date: _fmt(_date), reason: reason);
    if (!mounted) return;
    setState(() {
      final i = _recurring.indexWhere((r) => r.activity.id == s.activity.id);
      if (i >= 0) _recurring[i] = result;
    });
  }

  Future<void> _editRecurringEntry(RecurringActivityStatus s) async {
    if (s.entry == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEntryScreen(
          entry: s.entry!,
          family: widget.family,
          onSaved: _load,
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE d MMMM').format(_date).toUpperCase(),
                        style: TextStyle(
                            fontFamily: kFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                            color: kN600),
                      ),
                      const SizedBox(height: 5),
                      Text(_isToday ? 'Today' : DateFormat('EEEE').format(_date),
                          style: t.headlineLarge),
                    ],
                  ),
                ),
                ValueListenableBuilder<SyncStatus>(
                  valueListenable: SyncController.instance.statusNotifier,
                  builder: (_, status, __) => _SyncDot(status: status),
                ),
              ],
            ),
          ),

          _WeekStrip(
            date: _date,
            counts: _weekCounts,
            vacation: _weekVacation,
            onPick: (d) {
              setState(() => _date = d);
              _load();
            },
          ),

          // Log a visit
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModLabel('Log a visit'),
                const SizedBox(height: 9),
                if (_isFuture)
                  ModBox(
                    muted: true,
                    child: Text(
                      'Future date — only a vacation can be logged ahead.',
                      style: TextStyle(
                          fontFamily: kFont, fontSize: 12.5, color: c.txt2),
                    ),
                  )
                else ...[
                  if (_lastVisit.isNotEmpty)
                    InkWell(
                      onTap: _sameAsUsual,
                      child: Container(
                        width: double.infinity,
                        color: c.green,
                        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('SAME AS USUAL',
                                    style: TextStyle(
                                        fontFamily: kFont,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: Colors.white)),
                                const Icon(Icons.arrow_forward,
                                    size: 20, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _lastVisitSummary(),
                              style: const TextStyle(
                                  fontFamily: kFont,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xD9FFFFFF)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _shiftBox('morning')),
                    const SizedBox(width: 10),
                    Expanded(child: _shiftBox('evening')),
                  ]),
                ],
                const SizedBox(height: 11),
                Row(children: [
                  if (!_isFuture) ...[
                    _UnderlineAction(
                        label: 'Nobody went today',
                        color: kAccent700,
                        onTap: _logNobodyWent),
                    const SizedBox(width: 16),
                  ],
                  _UnderlineAction(
                      label: 'On vacation', color: kN700, onTap: _logVacation),
                ]),
              ],
            ),
          ),

          if (_recurring.isNotEmpty) ...[
            const ModRule(top: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModLabel(
                    'Planned for this day',
                    trailing: Text(
                      '${_recurring.where((r) => r.isConfirmed).length} OF ${_recurring.length} DONE',
                      style: const TextStyle(
                          fontFamily: kFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: kN600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._recurring.map((s) => RecurringActivityCard(
                        status: s,
                        onConfirm: () => _confirmRecurring(s),
                        onSkip: () => _skipRecurring(s),
                        onTapConfirmed: s.isConfirmed && s.entry != null
                            ? () => _editRecurringEntry(s)
                            : null,
                      )),
                ],
              ),
            ),
          ],

          const ModRule(top: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModLabel(_isToday
                    ? "Today's log"
                    : 'Log — ${AppSettings.instance.fmtDateShort(_fmt(_date))}'),
                const SizedBox(height: 10),
                if (_dayEntries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    child: Text('Nothing logged.',
                        style: TextStyle(
                            fontFamily: kFont, fontSize: 13.5, color: c.txt2)),
                  )
                else
                  ..._dayEntries.map((e) => _LogRow(
                        entry: e,
                        onTap: () => showEntryActions(
                          context,
                          entry: e,
                          family: widget.family,
                          onChanged: _load,
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _lastVisitSummary() {
    final e = _lastVisit.first;
    final parts = <String>[
      e.shift == 'morning' ? 'Morning' : 'Evening',
      e.userList.join(' & '),
      if (e.kidList.isNotEmpty) e.kidList.join(' & '),
      if (e.duration != null) e.duration!,
    ];
    return parts.join(' · ');
  }

  Widget _shiftBox(String shift) {
    final c = AppColors.of(context);
    final logged = _dayEntries.any(
        (e) => e.shift == shift && !e.vacation && !e.noPlayground);
    return ModBox(
      onTap: _isFuture ? null : () => _openSheet(shift),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shift.toUpperCase(),
              style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: c.txt)),
          const SizedBox(height: 2),
          Text(logged ? 'Logged' : 'Not logged',
              style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: logged ? c.green : kN600)),
        ],
      ),
    );
  }
}

// ── Week strip ────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final DateTime date;
  final Map<String, int> counts;
  final Map<String, bool> vacation;
  final ValueChanged<DateTime> onPick;

  const _WeekStrip({
    required this.date,
    required this.counts,
    required this.vacation,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final today = DateTime.now();

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
          final key = DateFormat('yyyy-MM-dd').format(d);
          final sel = d.year == date.year && d.month == date.month && d.day == date.day;
          final future = DateTime(d.year, d.month, d.day)
              .isAfter(DateTime(today.year, today.month, today.day));
          final n = counts[key] ?? 0;
          final vac = vacation[key] ?? false;

          Widget mark;
          if (vac) {
            mark = Container(width: 7, height: 7, color: c.txt);
          } else if (n >= 2) {
            mark = Container(width: 7, height: 7, color: sel ? Colors.white : c.green);
          } else if (n == 1) {
            mark = Container(width: 7, height: 7, color: kAccent300);
          } else {
            mark = Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                border: Border.all(
                    color: sel
                        ? Colors.white54
                        : c.border.withValues(alpha: 0.35),
                    width: 1.5),
              ),
            );
          }

          return Expanded(
            child: InkWell(
              onTap: () => onPick(d),
              child: Container(
                decoration: BoxDecoration(
                  color: sel ? c.txt : null,
                  border: Border(
                    right: i == 6
                        ? BorderSide.none
                        : BorderSide(
                            color: c.border.withValues(alpha: 0.4), width: 1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(d).substring(0, 1),
                      style: TextStyle(
                          fontFamily: kFont,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: sel ? Colors.white70 : kN600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                          fontFamily: kFont,
                          fontSize: 15,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                          color: sel
                              ? Colors.white
                              : future
                                  ? kN500
                                  : c.txt),
                    ),
                    const SizedBox(height: 5),
                    mark,
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Log row ───────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  final Entry entry;
  final VoidCallback onTap;
  const _LogRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final e = entry;

    final String kicker;
    final Color kickerColor;
    if (e.noPlayground) {
      kicker = 'NOBODY';
      kickerColor = kAccent700;
    } else if (e.vacation) {
      kicker = 'VACATION';
      kickerColor = kN700;
    } else {
      kicker = e.shift.toUpperCase();
      kickerColor = e.shift == 'morning' ? kAccent700 : kN700;
    }

    final detail = <String>[
      if (e.duration != null) e.duration!,
      if (e.kidList.isNotEmpty) e.kidList.join(' & '),
      if (e.activityList.isNotEmpty) e.activityList.join(', '),
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.4))),
        ),
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 62,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(kicker,
                    style: TextStyle(
                        fontFamily: kFont,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: kickerColor)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.userList.join(' & '),
                      style: TextStyle(
                          fontFamily: kFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.txt)),
                  if (detail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(detail,
                          style: TextStyle(
                              fontFamily: kFont, fontSize: 12, color: c.txt2)),
                    ),
                  if (e.excuse != null && e.excuse!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(e.excuse!,
                          style: TextStyle(
                              fontFamily: kFont,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: c.txt2)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlineAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _UnderlineAction(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Text(label,
            style: TextStyle(
                fontFamily: kFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                decoration: TextDecoration.underline,
                decorationColor: color)),
      );
}

class _SyncDot extends StatelessWidget {
  final SyncStatus status;
  const _SyncDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (status == SyncStatus.syncing) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2, color: c.green),
      );
    }
    final color = switch (status) {
      SyncStatus.synced => c.txt,
      SyncStatus.error => kAccent,
      _ => kN500,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(width: 9, height: 9, color: color),
    );
  }
}
