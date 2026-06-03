import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/family.dart';
import '../models/entry.dart';

import '../settings/app_settings.dart';
import '../theme.dart';

// Brand accent colours — intentionally fixed in both light and dark mode
const _kGreen   = kGreen;
const _kGreenLt = kGreenLt;
const _kAmber   = kAmber;
const _kBlue    = kBlue;
// _kCard / _kBorder / _kTxt / _kTxt2 / _kBg come from AppColors.of(context) per build()



const _colors = [
  Color(0xFF2e7d32), Color(0xFFc62828), Color(0xFF1565c0),
  Color(0xFFf57f17), Color(0xFF6a1b9a), Color(0xFF00838f),
  Color(0xFF558b2f), Color(0xFFad1457),
];

const _durMap = {
  '15 min': 15, '30 min': 30, '45 min': 45, '1 hour': 60,
  '1.5 hours': 90, '2 hours': 120, '2+ hours': 150,
};

class DashboardScreen extends StatefulWidget {
  final Family family;
  const DashboardScreen({super.key, required this.family});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Theme-aware colour getters — readable from any method on this State
  Color get _kCard   => AppColors.of(context).card;
  Color get _kBorder => AppColors.of(context).border;
  Color get _kTxt    => AppColors.of(context).txt;
  Color get _kTxt2   => AppColors.of(context).txt2;
  Color get _kBg     => AppColors.of(context).bg;

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
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

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

  DateTime _monday(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));
  String _ds(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _weekEnd(String start) => _ds(DateTime.parse(start).add(const Duration(days: 6)));

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

  String get _periodLabel {
    switch (_period) {
      case 'all':
        return 'All Time';
      case 'year':
        return _ref;
      case 'month':
        return AppSettings.instance.fmtMonth(_ref);
      case 'week':
        return AppSettings.instance.fmtWeekRange(_ref, _weekEnd(_ref));
      default:
        return '';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final _c2 = AppColors.of(context);
    final _kCard   = _c2.card;
    final _kBorder = _c2.border;
    final _kTxt    = _c2.txt;
    final _kTxt2   = _c2.txt2;
    final _kBg     = _c2.bg;



    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodTabs(),
          _buildPeriodNav(),
          if (_loading)
            Center(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator()))
          else if (_data != null)
            _buildContent(_data!),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    const labels = {'week': 'Week', 'month': 'Month', 'year': 'Year', 'all': 'All Time'};
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: ['week', 'month', 'year', 'all'].map((p) {
          final sel = p == _period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _period = p);
                _resetRef();
                _load();
              },
              child: Container(
                margin: EdgeInsets.only(right: p != 'all' ? 5 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? _kGreen : Colors.white,
                  border: Border.all(color: sel ? _kGreen : _kBorder, width: 2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  labels[p]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: sel ? Colors.white : _kTxt2,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodNav() => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Row(children: [
          Opacity(
            opacity: _period == 'all' ? 0.0 : 1.0,
            child: GestureDetector(
              onTap: _period == 'all' ? null : () => _bump(-1),
              child: Icon(Icons.chevron_left, color: _kGreen, size: 28),
            ),
          ),
          Expanded(
            child: Text(_periodLabel,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          Opacity(
            opacity: _period == 'all' ? 0.0 : 1.0,
            child: GestureDetector(
              onTap: _period == 'all' ? null : () => _bump(1),
              child: Icon(Icons.chevron_right, color: _kGreen, size: 28),
            ),
          ),
        ]),
      );

  Widget _buildContent(Map<String, dynamic> data) {
    final byUser = (data['by_user'] as Map?)?.cast<String, int>() ?? {};
    final byKid = (data['kids'] as Map?)?.cast<String, int>() ?? {};
    final shifts = (data['shifts'] as Map?)?.cast<String, int>() ?? {};
    final entries = (data['entries'] as List?)?.cast<Entry>() ?? [];
    final parents = (data['parents'] as List?)?.cast<String>() ?? widget.family.parents;
    final kids = (data['kids_list'] as List?)?.cast<String>() ?? widget.family.kids;
    final durStats = _calcDurStats(entries);
    final missed   = data['missed'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent stats
        _statsGrid(parents.map((p) => _statCard('${byUser[p] ?? 0}', p)).toList()),
        const SizedBox(height: 8),

        // Kid stats
        _statsGrid(kids.map((k) => _statCard('${byKid[k] ?? 0}', '$k outside')).toList()),
        const SizedBox(height: 8),

        // Duration + missed stats
        Row(children: [
          Expanded(child: _statCard(_fmtMins(durStats['avg']!), 'Avg duration', small: true)),
          const SizedBox(width: 8),
          Expanded(child: _statCard(_fmtMins(durStats['total']!), 'Total time', small: true)),
          const SizedBox(width: 8),
          Expanded(child: _statCard('$missed', 'No playground', small: true, accent: const Color(0xFFE53935))),
        ]),
        const SizedBox(height: 8),

        // Donut charts row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _chartCard(
                  title: 'Morning / Evening',
                  child: Column(children: [
                    DonutChart(
                      segments: [
                        DonutSegment(value: shifts['morning'] ?? 0, color: _kAmber),
                        DonutSegment(value: shifts['evening'] ?? 0, color: _kBlue),
                      ],
                      center: '${(shifts['morning'] ?? 0) + (shifts['evening'] ?? 0)}',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        _legend(_kAmber, 'Morning'),
                        _legend(_kBlue, 'Evening'),
                      ],
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _chartCard(
                  title: 'Who Went',
                  child: Column(children: [
                    DonutChart(
                      segments: parents.asMap().entries.map((e) => DonutSegment(
                            value: byUser[e.value] ?? 0,
                            color: _colors[e.key % _colors.length],
                          )).toList(),
                      center: '${byUser.values.fold(0, (a, b) => a + b)}',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: parents.asMap().entries
                          .map((e) => _legend(_colors[e.key % _colors.length], e.value))
                          .toList(),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Activity bars
        _chartCard(title: 'Top Activities', child: _buildActivityBars(entries)),
        const SizedBox(height: 8),

        // Log entries
        Text(
          'LOG',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: _kTxt2, letterSpacing: 0.6),
        ),
        const SizedBox(height: 6),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Text('No entries this period',
                style: TextStyle(color: _kTxt2, fontSize: 14)),
          )
        else
          ..._buildGroupedLog(entries),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _statsGrid(List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    // Pair items into rows of 2
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(Row(children: [
        Expanded(child: children[i]),
        if (i + 1 < children.length) ...[
          const SizedBox(width: 8),
          Expanded(child: children[i + 1]),
        ] else
          const Expanded(child: SizedBox()),
      ]));
      if (i + 2 < children.length) rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }

  Widget _buildActivityBars(List<Entry> entries) {
    final counts = <String, int>{};
    for (final e in entries) {
      if (!e.vacation) {
        for (final t in e.activityList) {
          counts[t] = (counts[t] ?? 0) + 1;
        }
      }
    }
    if (counts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('No activities logged yet', style: TextStyle(color: _kTxt2, fontSize: 13)),
        ),
      );
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    final maxVal = top.first.value;
    return Column(
      children: top.map((kv) {
        final pct = (kv.value / maxVal).clamp(0.03, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(children: [
            SizedBox(
              width: 68,
              child: Text(kv.key,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: _kTxt2)),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 16,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 24,
              child: Text('${kv.value}',
                  style: TextStyle(
                      fontSize: 11, color: _kTxt2, fontWeight: FontWeight.w600)),
            ),
          ]),
        );
      }).toList(),
    );
  }

  List<Widget> _buildGroupedLog(List<Entry> entries) {
    final grouped = <String, List<Entry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.date, () => []).add(e);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return dates.map((date) {
      final label = AppSettings.instance.fmtDateFull(date);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 3),
            child: Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _kTxt2, letterSpacing: 0.5)),
          ),
          ...grouped[date]!.map((e) => _DashEntryCard(entry: e)),
        ],
      );
    }).toList();
  }

  Widget _statCard(String num, String label, {bool small = false, Color? accent}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(num,
                style: TextStyle(
                    fontSize: small ? 22 : 34,
                    fontWeight: FontWeight.w800,
                    color: accent ?? _kGreen,
                    height: 1)),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: _kTxt2, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _chartCard({required String title, required Widget child}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Column(children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: _kTxt2, letterSpacing: 0.6)),
          const SizedBox(height: 10),
          child,
        ]),
      );

  Widget _legend(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: _kTxt2)),
        ],
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

// ── Donut chart ───────────────────────────────────────────

class DonutSegment {
  final int value;
  final Color color;
  const DonutSegment({required this.value, required this.color});
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final String center;

  const DonutChart({super.key, required this.segments, required this.center});

  @override
  Widget build(BuildContext context) {
    final _c2 = AppColors.of(context);
    final _kCard   = _c2.card;
    final _kBorder = _c2.border;
    final _kTxt    = _c2.txt;
    final _kTxt2   = _c2.txt2;
    final _kBg     = _c2.bg;



    final total = segments.fold<int>(0, (s, e) => s + e.value);
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(110, 110),
            painter: _DonutPainter(segments: segments, total: total),
          ),
          Center(
            child: Text(
              total == 0 ? '–' : center,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _kTxt),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final int total;
  const _DonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeW = size.width * 0.22;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeW / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = const Color(0xFFE0E0E0);
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double start = -math.pi / 2;
    for (final seg in segments) {
      if (seg.value == 0) continue;
      final sweep = (seg.value / total) * 2 * math.pi;
      paint.color = seg.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.total != total || old.segments.length != segments.length;
}

// ── Dashboard log entry card (no delete) ─────────────────

class _DashEntryCard extends StatelessWidget {
  final Entry entry;
  const _DashEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final _c2 = AppColors.of(context);
    final _kCard   = _c2.card;
    final _kBorder = _c2.border;
    final _kTxt    = _c2.txt;
    final _kTxt2   = _c2.txt2;
    final _kBg     = _c2.bg;



    final e = entry;
    final isM = e.shift == 'morning';
    final shiftBg = isM ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD);
    final shiftColor = isM ? const Color(0xFFBF360C) : const Color(0xFF0D47A1);
    final shiftLabel = isM ? '☀️ Morning' : '🌙 Evening';
    final userDisplay = e.userList.isEmpty ? e.user : e.userList.join(' & ');

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (e.noPlayground)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(11)),
                child: Text('❌ No playground',
                    style: TextStyle(
                        color: const Color(0xFFB71C1C), fontSize: 11, fontWeight: FontWeight.w700)),
              )
            else if (!e.vacation)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: shiftBg, borderRadius: BorderRadius.circular(11)),
                child: Text(shiftLabel,
                    style: TextStyle(
                        color: shiftColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            if (e.vacation)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(11)),
                child: Text('🏖️ Vacation',
                    style: TextStyle(
                        color: Color(0xFFB71C1C), fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(userDisplay,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ]),
          if (e.noPlayground && e.excuse != null && e.excuse!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('💬 ${e.excuse}',
                  style: TextStyle(fontSize: 13, color: _kTxt2, fontStyle: FontStyle.italic)),
            ),
          if (!e.vacation && !e.noPlayground) ...[
            const SizedBox(height: 5),
            Text(
              '⏱ ${e.duration ?? 'NA'}   ·   👧 ${e.kidList.isEmpty ? 'NA' : e.kidList.join(' & ')}',
              style: TextStyle(fontSize: 13, color: _kTxt2),
            ),
            if (e.activityList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Wrap(
                  spacing: 4, runSpacing: 4,
                  children: e.activityList.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEDF7ED),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(t,
                        style: TextStyle(
                            color: _kGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
