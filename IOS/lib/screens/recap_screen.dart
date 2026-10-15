import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/durations.dart';
import '../models/streak.dart';
import '../theme.dart';
import '../l10n/l10n.dart';

/// A "your month/year so far" snapshot — a fun, shareable-feeling summary,
/// distinct from the regular Dashboard's data-dense insights. Reuses the
/// same [DatabaseHelper.getDashboard] query the Dashboard runs.
class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  String _period = 'year'; // 'month' | 'year'
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final data = await DatabaseHelper.instance.getDashboard(
      period: _period,
      month: _period == 'month'
          ? '${now.year}-${now.month.toString().padLeft(2, '0')}'
          : null,
      year: _period == 'year' ? now.year.toString() : null,
    );
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final now = DateTime.now();
    final periodLabel = _period == 'month'
        ? toBeginningOfSentenceCase(DateFormat('LLLL').format(now))
        : '${now.year}';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(context.l10n.recap,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _segmented(c),
                const SizedBox(height: 18),
                _RecapBody(data: _data!, periodLabel: periodLabel, c: c),
              ],
            ),
    );
  }

  Widget _segmented(AppColors c) => Row(
        children: [
          Expanded(child: _seg('month', context.l10n.thisMonth, c)),
          const SizedBox(width: 8),
          Expanded(child: _seg('year', context.l10n.thisYear, c)),
        ],
      );

  Widget _seg(String value, String label, AppColors c) {
    final sel = value == _period;
    return GestureDetector(
      onTap: () {
        setState(() => _period = value);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: sel ? c.green : c.card,
          border: Border.all(color: sel ? c.green : c.border, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: sel ? c.onAccent : c.txt2,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _RecapBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final String periodLabel;
  final AppColors c;
  const _RecapBody({required this.data, required this.periodLabel, required this.c});

  @override
  Widget build(BuildContext context) {
    final entries = (data['entries'] as List).cast<Entry>();
    final byUser = (data['by_user'] as Map).cast<String, int>();
    final byKid = (data['kids'] as Map).cast<String, int>();
    final real = entries.where((e) => !e.vacation && !e.noPlayground).toList();

    if (real.isEmpty) {
      return _EmptyRecap(periodLabel: periodLabel, c: c);
    }

    final totalVisits = real.length;
    final totalMinutes = real.fold<int>(
        0, (sum, e) => sum + durationMinutes(e.duration));
    final topActivity = _topOf(_activityCounts(real));
    final topParent = _topOf(byUser);
    final topKid = _topOf(byKid);
    final streak = longestStreak(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: c.green,
            borderRadius: BorderRadius.zero,
          ),
          child: Column(children: [
            Text(periodLabel.toUpperCase(),
                style: TextStyle(
                    color: c.onAccent.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('$totalVisits',
                style: TextStyle(
                    color: c.onAccent,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1)),
            Text(context.l10n.playgroundVisits(totalVisits),
                style: TextStyle(color: c.onAccent, fontSize: 16)),
            if (totalMinutes > 0) ...[
              const SizedBox(height: 14),
              Text(context.l10n.outsideAsFamily(_fmtMins(totalMinutes)),
                  style: TextStyle(
                      color: c.onAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Stat row
        Row(children: [
          if (streak > 1) ...[
            Expanded(child: _statCard(context.l10n.daysCount(streak), context.l10n.longestStreak, c)),
            const SizedBox(width: 10),
          ],
          if (topActivity != null) ...[
            Expanded(child: _statCard(topActivity, context.l10n.topActivity, c)),
            const SizedBox(width: 10),
          ],
          if (topParent != null)
            Expanded(child: _statCard(topParent, context.l10n.wentTheMost, c)),
        ]),

        if (topKid != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.zero,
            ),
            child: Row(children: [
              Icon(Icons.emoji_people_outlined, size: 20, color: c.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(context.l10n.kidOutsideMost(topKid),
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: c.txt)),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 20),
        Center(
          child: Text(
            _tagline(context, totalVisits, periodLabel),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: c.txt2, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, AppColors c) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.zero,
        ),
        child: Column(children: [
          Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: c.txt)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: c.txt2)),
        ]),
      );

  Map<String, int> _activityCounts(List<Entry> real) {
    final counts = <String, int>{};
    for (final e in real) {
      for (final a in e.activityList) {
        counts[a] = (counts[a] ?? 0) + 1;
      }
    }
    return counts;
  }

  String? _topOf(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    final sorted = counts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.isEmpty ? null : sorted.first.key;
  }

  String _fmtMins(int m) {
    final h = m ~/ 60, mn = m % 60;
    if (h > 0 && mn > 0) return '${h}h ${mn}m';
    if (h > 0) return '${h}h';
    return '${mn}m';
  }

  String _tagline(BuildContext context, int visits, String period) {
    if (visits >= 20) return context.l10n.taglineLots;
    if (visits >= 8) return context.l10n.taglineSolid(period);
    return context.l10n.taglineEvery;
  }
}

class _EmptyRecap extends StatelessWidget {
  final String periodLabel;
  final AppColors c;
  const _EmptyRecap({required this.periodLabel, required this.c});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(children: [
          Icon(Icons.park_outlined, size: 40, color: c.txt2),
          const SizedBox(height: 16),
          Text(context.l10n.recapEmpty(periodLabel),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.txt)),
          const SizedBox(height: 6),
          Text(context.l10n.recapEmptyHint,
              style: TextStyle(fontSize: 13, color: c.txt2)),
        ]),
      );
}
