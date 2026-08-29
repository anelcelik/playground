import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';
import '../models/family.dart';
import '../sync/sync_controller.dart';
import '../sync/sync_service.dart';
import '../services/recurring_service.dart';
import '../services/quick_action_service.dart';
import '../widgets/modernist.dart';
import 'today_screen.dart';
import 'dashboard_screen.dart';
import 'manage_recurring_screen.dart';
import 'settings_screen.dart';

/// Four destinations in a bottom tab bar, replacing the green AppBar +
/// top TabBar + gear PopupMenuButton. Recap and Recurring Activities used
/// to live inside that popup; they are content, not settings, so Recurring
/// is now the Plans tab and Recap sits at the top of History.
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
    // A shortcut tap can race main()'s init — it may already be sitting on
    // the notifier by the time we mount, so fold it into the start index.
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
    QuickActionService.instance.lastAction.value = null; // consumed
  }

  Future<void> _loadFamily() async {
    final f = await DatabaseHelper.instance.getFamily();
    if (mounted) setState(() => _family = f);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    if (_family.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final tabs = [
      TodayScreen(
        family: _family,
        onEntrySaved: () => SyncService.instance.sync(),
        onSeeHistory: () => setState(() => _index = 1),
      ),
      DashboardScreen(family: _family),
      const ManageRecurringScreen(),
      SettingsScreen(family: _family, onFamilyChanged: _loadFamily),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: tabs[_index]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Rule(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Row(
                children: [
                  _Tab(
                      icon: Icons.calendar_today_outlined,
                      label: 'Today',
                      selected: _index == 0,
                      onTap: () => setState(() => _index = 0)),
                  _Tab(
                      icon: Icons.bar_chart_rounded,
                      label: 'History',
                      selected: _index == 1,
                      onTap: () => setState(() => _index = 1)),
                  _Tab(
                      icon: Icons.repeat_rounded,
                      label: 'Plans',
                      selected: _index == 2,
                      onTap: () => setState(() => _index = 2)),
                  _Tab(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      selected: _index == 3,
                      onTap: () => setState(() => _index = 3),
                      // The sync dot moved out of the AppBar and onto the
                      // Settings tab, where sync actually lives.
                      badge: ValueListenableBuilder<SyncStatus>(
                        valueListenable: SyncController.instance.statusNotifier,
                        builder: (_, status, __) => _SyncDot(status: status),
                      )),
                ]
                    .map((t) => Expanded(child: t))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: c.bg,
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? badge;
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = selected ? c.green : c.txt2;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 21, color: fg),
                  if (badge != null)
                    Positioned(right: -4, top: -2, child: badge!),
                ],
              ),
              const SizedBox(height: 3),
              Text(label.toUpperCase(),
                  style: AppType.label.copyWith(
                      color: fg, fontSize: 9.5, letterSpacing: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sync state as a 7px square — squares, not circles, per the system.
class _SyncDot extends StatelessWidget {
  final SyncStatus status;
  const _SyncDot({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == SyncStatus.synced || status == SyncStatus.unavailable) {
      return const SizedBox.shrink();
    }
    final color = switch (status) {
      SyncStatus.syncing => const Color(0xFFF5A623),
      SyncStatus.error => AppColors.of(context).green,
      _ => AppColors.of(context).hairline,
    };
    return Container(width: 7, height: 7, color: color);
  }
}
