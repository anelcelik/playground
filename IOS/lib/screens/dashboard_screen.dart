import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/dashboard_prefs.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../settings/app_settings.dart';
import '../sync/sync_service.dart';
import '../theme.dart';
import '../widgets/entry_actions.dart';
import '../widgets/modernist.dart';
import 'dashboard_customise_screen.dart';

const _durMap = {
  '15 min': 15, '30 min': 30, '45 min': 45, '1 hour': 60,
  '1.5 hours': 90, '2 hours': 120, '2+ hours': 150,
};

const _monthNames = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/// The History tab.
///
/// One square per day is the centrepiece: a month reads as a block of colour
/// before you read a single number. Everything else is a labelled block with
/// a rule under it — no cards, no shadows, no donuts.
class DashboardScreen extends StatefulWidget {
  final Family family;
  const DashboardScreen({super.key, required this.family});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _period = 'month';
  String _ref = '';
  Map<String, dynamic>? _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _resetRef();
    _load();
    AppSettings.instance.addListener(_onSettingsChanged);
    DashboardPrefs.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettingsChanged);
    DashboardPrefs.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  // ── Period bookkeeping ──────────────────────────────────

  void _resetRef() {
    final t = DateTime.now();
    switch (_period) {
      case 'week':
        _ref = _ds(_monday(t));
      case 'month':
        _ref = '${t.year}-${t.month.toString().padLeft(2, '0')}';
      case 'year':
        _ref = t.year.toString();
      default:
        _ref = '';
    }
  }

  DateTime _monday(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  String _ds(DateTime d) => '${d.year}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _weekEnd(String start) =>
      _ds(DateTime.parse(start).add(const Duration(days: 6)));

  void _bump(int dir) {
    setState(() {
      switch (_period) {
        case 'week':
          _ref = _ds(DateTime.parse(_ref).add(Duration(days: dir * 7)));
        case 'month':
          final p = _ref.split('-').map(int.parse).toList();
          final next = DateTime(p[0], p[1] + dir, 1);
          _ref = '${next.year}-${next.month.toString().padLeft(2, '0')}';
        case 'year':
          _ref = (int.parse(_ref) + dir).toString();
        default:
          break;
      }
    });
    _load();
  }

  String get _periodLabel => switch (_period) {
        'all' => 'All time',
        'year' => _ref,
        'month' => AppSettings.instance.fmtMonth(_ref),
        'week' => AppSettings.instance.fmtWeekRange(_ref, _weekEnd(_ref)),
        _ => '',
      };

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await DatabaseHelper.instance.getDashboard(
      period: _period,
      weekStart: _period == 'week' ? _ref : null,
      weekEnd: _period == 'week' ? _weekEnd(_ref) : null,
      month: _period == 'month' ? _ref : null,
      year: _period == 'year' ? _ref : null,
    );
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  // ── Chrome ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Text('History',
                    style: AppType.title.copyWith(color: c.txt)),
              ),
              Semantics(
                button: true,
                label: 'Customise dashboard',
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardCustomiseScreen()),
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.tune_rounded, size: 20, color: c.txt2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Rule(),
        _segmented(c),
        const Rule(),
        _navStrip(c),
        const Rule(),
        Expanded(
          child: _loading
              ? Center(
                  child: SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: c.hairline,
                        color: c.green),
                  ),
                )
              : _data == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 28),
                      children: _content(c, _data!),
                    ),
        ),
      ],
    );
  }

  /// WEEK · MONTH · YEAR · ALL — selected cell fills solid ink.
  Widget _segmented(AppColors c) {
    const labels = {
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
      'all': 'All',
    };
    final keys = labels.keys.toList();

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          for (var i = 0; i < keys.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: keys[i] == _period,
                child: InkWell(
                  onTap: () {
                    setState(() => _period = keys[i]);
                    _resetRef();
                    _load();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: keys[i] == _period ? c.txt : Colors.transparent,
                      border: i == 0
                          ? null
                          : Border(
                              left: BorderSide(color: c.hairline, width: 1)),
                    ),
                    child: Text(
                      labels[keys[i]]!.toUpperCase(),
                      style: AppType.label.copyWith(
                          color: keys[i] == _period ? c.bg : c.txt2,
                          fontSize: 11),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navStrip(AppColors c) {
    final locked = _period == 'all';
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          _navArrow(c, Icons.chevron_left, locked ? null : () => _bump(-1)),
          Expanded(
            child: Center(
              child: Text(
                _periodLabel.toUpperCase(),
                style: AppType.label
                    .copyWith(color: c.txt, fontSize: 11, letterSpacing: 1.2),
              ),
            ),
          ),
          _navArrow(c, Icons.chevron_right, locked ? null : () => _bump(1)),
        ],
      ),
    );
  }

  Widget _navArrow(AppColors c, IconData icon, VoidCallback? onTap) => Opacity(
        opacity: onTap == null ? 0 : 1,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 52,
            height: 40,
            child: Icon(icon, size: 24, color: c.txt),
          ),
        ),
      );

  // ── Content ─────────────────────────────────────────────

  List<Widget> _content(AppColors c, Map<String, dynamic> data) {
    final entries = (data['entries'] as List?)?.cast<Entry>() ?? [];
    final byUser = (data['by_user'] as Map?)?.cast<String, int>() ?? {};
    final byKid = (data['kids'] as Map?)?.cast<String, int>() ?? {};
    final shifts = (data['shifts'] as Map?)?.cast<String, int>() ?? {};
    final parents =
        (data['parents'] as List?)?.cast<String>() ?? widget.family.parents;
    final kids =
        (data['kids_list'] as List?)?.cast<String>() ?? widget.family.kids;
    final missed = data['missed'] as int? ?? 0;
    final durStats = _calcDurStats(entries);

    final sections = <String, Widget?>{
      'parent_stats': _barBlock(
        c,
        'Who took them',
        [for (final p in parents) (p, byUser[p] ?? 0)],
        emptyNote: 'Nobody logged yet',
      ),
      'calendar': _calendarBlock(c, entries),
      'kid_stats': _barBlock(
        c,
        'Kids outside',
        [for (final k in kids) (k, byKid[k] ?? 0)],
        emptyNote: 'No kids logged yet',
      ),
      'time_stats': _timeBlock(c, durStats['avg']!, missed),
      'charts': _barBlock(
        c,
        'Morning / evening',
        [
          ('Morning', shifts['morning'] ?? 0),
          ('Evening', shifts['evening'] ?? 0),
        ],
        emptyNote: 'No visits this period',
      ),
      'activities': _activitiesBlock(c, entries),
      'missed_reasons': _reasonsBlock(c, entries, missed),
      'log': _logBlock(c, entries),
    };

    final out = <Widget>[
      _hero(c, _countVisitDays(entries), durStats['total']!),
      const Rule(),
    ];

    for (final section in DashboardPrefs.instance.sections) {
      if (!section.visible) continue;
      final w = sections[section.id];
      if (w == null) continue;
      out.add(w);
      out.add(const Rule());
    }
    return out;
  }

  /// The headline pair — visit count in accent, time outside in ink.
  Widget _hero(AppColors c, int visits, int totalMins) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4,
              child: _figure(c, '$visits', 'Visits in $_periodLabel',
                  size: 58, color: c.green),
            ),
            Expanded(
              flex: 5,
              child: _figure(c, _fmtMins(totalMins), 'Outside',
                  size: 28, color: c.txt),
            ),
          ],
        ),
      );

  Widget _figure(AppColors c, String value, String label,
          {required double size, required Color color}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.figure.copyWith(
                  fontSize: size,
                  color: color,
                  letterSpacing: size > 40 ? -2.4 : -0.8)),
          const SizedBox(height: 8),
          Text(label.toUpperCase(),
              style: AppType.label.copyWith(color: c.txt2)),
        ],
      );

  // ── One square per day ──────────────────────────────────

  /// Per-date state for the grid. Vacation wins over everything, then the
  /// number of distinct parents who went that day.
  static const _dayNone = 0;
  static const _dayOne = 1;
  static const _dayBoth = 2;
  static const _dayVacation = 3;

  Map<String, int> _dayStates(List<Entry> entries) {
    final parentsByDate = <String, Set<String>>{};
    final vacationDates = <String>{};

    for (final e in entries) {
      if (e.vacation) {
        vacationDates.add(e.date);
        continue;
      }
      if (e.noPlayground) continue;
      final who = e.userList.isEmpty ? [e.user] : e.userList;
      parentsByDate.putIfAbsent(e.date, () => <String>{}).addAll(who);
    }

    final out = <String, int>{};
    for (final entry in parentsByDate.entries) {
      out[entry.key] = entry.value.length >= 2 ? _dayBoth : _dayOne;
    }
    for (final d in vacationDates) {
      out[d] = _dayVacation;
    }
    return out;
  }

  int _countVisitDays(List<Entry> entries) => _dayStates(entries)
      .values
      .where((s) => s == _dayOne || s == _dayBoth)
      .length;

  Color? _squareFill(AppColors c, int state) => switch (state) {
        _dayBoth => c.green,
        _dayOne => c.accentLt,
        _dayVacation => c.txt,
        _ => null,
      };

  Widget? _calendarBlock(AppColors c, List<Entry> entries) {
    if (_period == 'all') return null;

    final states = _dayStates(entries);
    final List<(String, int)> cells; // (tooltip, state)
    final int columns;
    final String label;

    switch (_period) {
      case 'week':
        final start = DateTime.parse(_ref);
        cells = [
          for (var i = 0; i < 7; i++)
            () {
              final d = start.add(Duration(days: i));
              return (_ds(d), states[_ds(d)] ?? _dayNone);
            }()
        ];
        columns = 7;
        label = 'This week  ·  one square per day';

      case 'year':
        // A year of days is unreadable at this size — one square per month,
        // shaded by how full the month was.
        final byMonth = <int, int>{};
        for (final e in states.entries) {
          if (e.value == _dayNone) continue;
          final m = int.parse(e.key.split('-')[1]);
          byMonth[m] = (byMonth[m] ?? 0) + 1;
        }
        final peak = byMonth.values.fold(0, (a, b) => a > b ? a : b);
        cells = [
          for (var m = 1; m <= 12; m++)
            (
              _monthNames[m - 1],
              switch (byMonth[m] ?? 0) {
                0 => _dayNone,
                final v when peak > 0 && v >= peak * 0.6 => _dayBoth,
                _ => _dayOne,
              }
            )
        ];
        columns = 6;
        label = '$_ref  ·  one square per month';

      default: // month
        final parts = _ref.split('-').map(int.parse).toList();
        final first = DateTime(parts[0], parts[1], 1);
        final days = DateTime(parts[0], parts[1] + 1, 0).day;
        final pad = first.weekday - 1; // Monday-first
        cells = [
          for (var i = 0; i < pad; i++) ('', -1),
          for (var d = 1; d <= days; d++)
            () {
              final ds = _ds(DateTime(parts[0], parts[1], d));
              return ('$d', states[ds] ?? _dayNone);
            }()
        ];
        columns = 7;
        label = '${AppSettings.instance.fmtMonth(_ref)}  ·  one square per day';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              for (final (tip, state) in cells)
                if (state < 0)
                  const SizedBox.shrink()
                else
                  Tooltip(
                    message: tip,
                    waitDuration: const Duration(milliseconds: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _squareFill(c, state),
                        border: state == _dayNone
                            ? Border.all(color: c.hairline, width: 1)
                            : null,
                      ),
                    ),
                  ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _legend(c, _dayBoth, _period == 'year' ? 'Busy' : 'Both'),
              _legend(c, _dayOne, _period == 'year' ? 'Some' : 'One'),
              _legend(c, _dayNone, 'None'),
              if (_period != 'year') _legend(c, _dayVacation, 'Vacation'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(AppColors c, int state, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: _squareFill(c, state),
              border: state == _dayNone
                  ? Border.all(color: c.hairline, width: 1)
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: AppType.label
                  .copyWith(color: c.txt2, fontSize: 9, letterSpacing: 0.9)),
        ],
      );

  // ── Bar blocks ──────────────────────────────────────────

  Widget _barBlock(AppColors c, String title, List<(String, int)> rows,
      {required String emptyNote}) {
    final shown = rows.where((r) => r.$2 > 0).toList();
    final peak = rows.fold(0, (a, r) => r.$2 > a ? r.$2 : a);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(title),
        if (shown.isEmpty)
          _note(c, emptyNote)
        else
          for (final (label, value) in rows)
            _bar(c, label, value, peak),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _bar(AppColors c, String label, int value, int peak) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.heading.copyWith(color: c.txt, fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Text('$value',
                    style:
                        AppType.heading.copyWith(color: c.txt, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (_, cs) => Stack(
                children: [
                  Container(
                      height: 8, color: c.isDark ? kInkD2 : kPaper2),
                  Container(
                    height: 8,
                    width: peak == 0 ? 0 : cs.maxWidth * (value / peak),
                    color: c.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _activitiesBlock(AppColors c, List<Entry> entries) {
    final counts = <String, int>{};
    for (final e in entries) {
      if (e.vacation || e.noPlayground) continue;
      for (final t in e.activityList) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _barBlock(
      c,
      'Most played',
      [for (final kv in sorted.take(6)) (kv.key, kv.value)],
      emptyNote: 'No activities logged yet',
    );
  }

  Widget _timeBlock(AppColors c, int avgMins, int missed) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Time & missed days'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _figure(c, _fmtMins(avgMins), 'Average visit',
                      size: 28, color: c.txt),
                ),
                Expanded(
                  child: _figure(c, '$missed', 'Nobody went',
                      size: 28, color: missed == 0 ? c.txt : c.green),
                ),
              ],
            ),
          ),
        ],
      );

  /// Reasons as chips — "RAIN · 4" — rather than a second bar chart.
  Widget _reasonsBlock(AppColors c, List<Entry> entries, int missed) {
    final counts = <String, int>{};
    for (final e in entries) {
      if (!e.noPlayground || e.excuse == null) continue;
      for (final t in e.excuse!
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Why nobody went'),
        if (sorted.isEmpty)
          _note(
              c,
              missed == 0
                  ? 'No missed days this period'
                  : 'No reasons logged yet')
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kv in sorted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration:
                        Border.all(color: c.hairline, width: 2).toBoxDecoration(),
                    child: Text('${kv.key.toUpperCase()}  ·  ${kv.value}',
                        style: AppType.label
                            .copyWith(color: c.txt, fontSize: 10)),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Log ─────────────────────────────────────────────────

  Widget _logBlock(AppColors c, List<Entry> entries) {
    if (entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Log'),
          _note(c, 'No entries this period'),
        ],
      );
    }

    final grouped = <String, List<Entry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.date, () => []).add(e);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Log'),
        for (final date in dates) ...[
          SectionLabel(AppSettings.instance.fmtDateFull(date),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 6)),
          for (final e in grouped[date]!) ...[
            const Hairline(),
            _logRow(c, e),
          ],
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _logRow(AppColors c, Entry e) {
    final who = e.userList.isEmpty ? e.user : e.userList.join(' & ');
    final String tag;
    if (e.noPlayground) {
      tag = 'Nobody went';
    } else if (e.vacation) {
      tag = 'Vacation';
    } else {
      tag = e.shift == 'morning' ? 'Morning' : 'Evening';
    }

    final detail = <String>[
      if (!e.vacation && !e.noPlayground && e.duration != null) e.duration!,
      if (!e.vacation && !e.noPlayground && e.kidList.isNotEmpty)
        e.kidList.join(' & '),
      if (e.noPlayground && (e.excuse?.isNotEmpty ?? false)) e.excuse!,
    ];

    return InkWell(
      onTap: () => showEntryActions(
        context,
        entry: e,
        family: widget.family,
        onChanged: () {
          _load();
          SyncService.instance.sync();
        },
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 34,
              margin: const EdgeInsets.only(right: 12, top: 2),
              color: e.noPlayground || e.vacation ? c.hairline : c.green,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(who,
                      style:
                          AppType.heading.copyWith(color: c.txt, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(
                    [tag, ...detail].join('  ·  '),
                    style: AppType.bodySm.copyWith(color: c.txt2),
                  ),
                  if (e.activityList.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final a in e.activityList)
                          Text(a.toUpperCase(),
                              style: AppType.label.copyWith(
                                  color: c.accentTxt,
                                  fontSize: 9,
                                  letterSpacing: 0.9)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: c.txt2),
          ],
        ),
      ),
    );
  }

  // ── Small shared pieces ─────────────────────────────────

  Widget _note(AppColors c, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: Text(text, style: AppType.body.copyWith(color: c.txt2)),
      );

  Map<String, int> _calcDurStats(List<Entry> entries) {
    final vals = entries
        .where((e) => !e.vacation && !e.noPlayground && e.duration != null)
        .map((e) => _durMap[e.duration] ?? 0)
        .where((v) => v > 0)
        .toList();
    if (vals.isEmpty) return {'avg': 0, 'total': 0};
    final total = vals.reduce((a, b) => a + b);
    return {'avg': (total / vals.length).round(), 'total': total};
  }

  String _fmtMins(int m) {
    if (m == 0) return '–';
    final h = m ~/ 60, mn = m % 60;
    if (h > 0 && mn > 0) return '${h}h ${mn}m';
    if (h > 0) return '${h}h';
    return '${mn}m';
  }
}

extension on Border {
  BoxDecoration toBoxDecoration() => BoxDecoration(border: this);
}
