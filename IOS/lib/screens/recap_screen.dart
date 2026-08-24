import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../theme.dart';

const _durMap = {
  '15 min': 15, '30 min': 30, '45 min': 45, '1 hour': 60,
  '1.5 hours': 90, '2 hours': 120, '2+ hours': 150,
};

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
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final periodLabel = _period == 'month' ? monthNames[now.month] : '${now.year}';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('🎉 Recap',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
          Expanded(child: _seg('month', 'This Month', c)),
          const SizedBox(width: 8),
          Expanded(child: _seg('year', 'This Year', c)),
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
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: sel ? Colors.white : c.txt2,
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
        0, (sum, e) => sum + (_durMap[e.duration] ?? 0));
    final topActivity = _topOf(_activityCounts(real));
    final topParent = _topOf(byUser);
    final topKid = _topOf(byKid);
    final streak = _longestStreak(real);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: c.green,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: [
            Text(periodLabel.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('$totalVisits',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1)),
            Text(totalVisits == 1 ? 'playground visit' : 'playground visits',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            if (totalMinutes > 0) ...[
              const SizedBox(height: 14),
              Text('${_fmtMins(totalMinutes)} outside as a family',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Stat row
        Row(children: [
          if (streak > 1) ...[
            Expanded(child: _statCard('$streak days', 'Longest streak', c)),
            const SizedBox(width: 10),
          ],
          if (topActivity != null) ...[
            Expanded(child: _statCard(topActivity, 'Top activity', c)),
            const SizedBox(width: 10),
          ],
          if (topParent != null)
            Expanded(child: _statCard(topParent, 'Went the most', c)),
        ]),

        if (topKid != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Text('👧', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('$topKid got outside the most',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: c.txt)),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 20),
        Center(
          child: Text(
            _tagline(totalVisits, periodLabel),
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
          borderRadius: BorderRadius.circular(16),
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

  /// Longest run of consecutive calendar days with at least one real visit.
  int _longestStreak(List<Entry> real) {
    final dates = real.map((e) => DateTime.parse(e.date)).toSet().toList()
      ..sort();
    if (dates.isEmpty) return 0;
    var longest = 1, current = 1;
    for (var i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  String _fmtMins(int m) {
    final h = m ~/ 60, mn = m % 60;
    if (h > 0 && mn > 0) return '${h}h ${mn}m';
    if (h > 0) return '${h}h';
    return '${mn}m';
  }

  String _tagline(int visits, String period) {
    if (visits >= 20) return "That's a lot of fresh air — well done. 🌳";
    if (visits >= 8) return 'A solid $period outside. Keep it up.';
    return 'Every visit counts — here\'s to more of them.';
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
          const Text('🌳', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Nothing logged yet for $periodLabel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.txt)),
          const SizedBox(height: 6),
          Text('Log a visit and it\'ll show up here.',
              style: TextStyle(fontSize: 13, color: c.txt2)),
        ]),
      );
}
