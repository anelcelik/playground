import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/family.dart';
import '../services/quick_action_service.dart';
import '../services/recurring_service.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'manage_recurring_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

/// Bottom tab shell. Replaces the green AppBar + top TabBar + gear popup.
///
/// Four destinations, no dropdown:
///   Today · History · Plans · Settings
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  Family _family = const Family(parents: [], kids: []);

  @override
  void initState() {
    super.initState();

    // A Home Screen shortcut can land before we mount — fold it into the
    // starting tab rather than animating one that doesn't exist yet.
    final pending = QuickActionService.instance.lastAction.value;
    if (pending == QuickActionService.dashboardType) _index = 1;
    if (pending != null) QuickActionService.instance.lastAction.value = null;

    _loadFamily();
    RecurringService.instance.autoMarkMissed();
    QuickActionService.instance.lastAction.addListener(_onQuickAction);
  }

  @override
  void dispose() {
    QuickActionService.instance.lastAction.removeListener(_onQuickAction);
    super.dispose();
  }

  void _onQuickAction() {
    final type = QuickActionService.instance.lastAction.value;
    if (type == null) return;
    setState(() {
      _index = type == QuickActionService.dashboardType ? 1 : 0;
    });
    QuickActionService.instance.lastAction.value = null;
  }

  Future<void> _loadFamily() async {
    final f = await DatabaseHelper.instance.getFamily();
    if (mounted) setState(() => _family = f);
  }

  @override
  Widget build(BuildContext context) {
    if (_family.isEmpty) {
      return const Scaffold(
        body: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: kAccent),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          TodayScreen(family: _family),
          _HistoryTab(family: _family),
          const ManageRecurringScreen(),
          SettingsScreen(onFamilyChanged: _loadFamily),
        ],
      ),
      bottomNavigationBar: _ModTabBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// DashboardScreen is a body widget (it used to sit inside a TabBarView), so
/// it gets the large title here rather than carrying one of its own.
class _HistoryTab extends StatelessWidget {
  final Family family;
  const _HistoryTab({required this.family});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('History',
                style: Theme.of(context).textTheme.headlineLarge),
          ),
          Expanded(child: DashboardScreen(family: family)),
        ],
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────
// Flat, 2px top rule, flush cells. Lucide-equivalent Material glyphs.

class _ModTabBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _ModTabBar({required this.index, required this.onTap});

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.calendar_today_outlined, label: 'Today'),
    (icon: Icons.bar_chart_rounded, label: 'History'),
    (icon: Icons.repeat_rounded, label: 'Plans'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(top: BorderSide(color: c.border, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: List.generate(_items.length, (i) {
              final on = i == index;
              final col = on ? c.green : kN600;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_items[i].icon, size: 21, color: col),
                      const SizedBox(height: 3),
                      Text(
                        _items[i].label.toUpperCase(),
                        style: TextStyle(
                            fontFamily: kFont,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: col),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
