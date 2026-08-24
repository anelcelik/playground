import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart' show AppColors;
import '../models/family.dart';
import '../sync/sync_controller.dart';
import '../sync/sync_service.dart';
import '../services/recurring_service.dart';
import '../services/quick_action_service.dart';
import 'setup_screen.dart';
import 'entry_screen.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';
import 'manage_recurring_screen.dart';
import 'display_settings_screen.dart';
import 'invite_family_screen.dart';
import 'recap_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Family _family = const Family(parents: [], kids: []);
  bool _showInviteBanner = false;

  @override
  void initState() {
    super.initState();
    // A shortcut tap can race main()'s init — it may already be sitting on
    // the notifier by the time we mount. Fold that into the controller's
    // starting index directly, rather than animating a tab view that
    // doesn't exist yet.
    final pending = QuickActionService.instance.lastAction.value;
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: pending == QuickActionService.dashboardType ? 1 : 0,
    );
    if (pending != null) QuickActionService.instance.lastAction.value = null;

    _loadFamily();
    RecurringService.instance.autoMarkMissed();
    _checkInviteBanner();

    // Any shortcut tapped while the app is already running arrives here.
    QuickActionService.instance.lastAction.addListener(_onQuickAction);
  }

  @override
  void dispose() {
    QuickActionService.instance.lastAction.removeListener(_onQuickAction);
    _tabs.dispose();
    super.dispose();
  }

  void _onQuickAction() {
    final type = QuickActionService.instance.lastAction.value;
    if (type == null) return;
    switch (type) {
      case QuickActionService.logEntryType:
        _tabs.animateTo(0);
      case QuickActionService.dashboardType:
        _tabs.animateTo(1);
    }
    QuickActionService.instance.lastAction.value = null; // consumed
  }

  Future<void> _loadFamily() async {
    final f = await DatabaseHelper.instance.getFamily();
    if (mounted) setState(() => _family = f);
  }

  /// Show the invite banner if the user hasn't dismissed it and no one
  /// has connected yet (only relevant on iOS where CloudKit is available).
  Future<void> _checkInviteBanner() async {
    final dismissed =
        await DatabaseHelper.instance.getMeta('invite_banner_dismissed');
    if (dismissed == '1') return;
    if (mounted) setState(() => _showInviteBanner = true);
  }

  Future<void> _dismissBanner() async {
    await DatabaseHelper.instance.setMeta('invite_banner_dismissed', '1');
    if (mounted) setState(() => _showInviteBanner = false);
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetupScreen(
          isEditing: true,
          initialParents: _family.parents,
          initialKids: _family.kids,
          onComplete: () {
            Navigator.pop(context);
            _loadFamily();
            SyncService.instance.sync();
          },
        ),
      ),
    );
  }

  void _openInvite() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InviteFamilyScreen()),
    ).then((_) {
      // Re-check banner after returning — if someone connected, hide it
      _checkInviteBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black26,
        title: const Text(
          '🌳 Playground Tracker',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          // Live sync-status dot
          ValueListenableBuilder<SyncStatus>(
            valueListenable: SyncController.instance.statusNotifier,
            builder: (_, status, __) => _SyncDot(status: status),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Notification settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            tooltip: 'Settings',
            onSelected: (v) {
              if (v == 'family') _openSettings();
              if (v == 'sync') _openInvite();
              if (v == 'recurring') {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ManageRecurringScreen()));
              }
              if (v == 'display') {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const DisplaySettingsScreen()));
              }
              if (v == 'recap') {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const RecapScreen()));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'recap',
                  child: Row(children: [
                    Icon(Icons.auto_awesome_rounded),
                    SizedBox(width: 10),
                    Text('Recap'),
                  ])),
              PopupMenuItem(
                  value: 'family',
                  child: Row(children: [
                    Icon(Icons.people_outline),
                    SizedBox(width: 10),
                    Text('Family Settings'),
                  ])),
              PopupMenuItem(
                  value: 'sync',
                  child: Row(children: [
                    Icon(Icons.sync_rounded),
                    SizedBox(width: 10),
                    Text('Family Sync'),
                  ])),
              PopupMenuItem(
                  value: 'recurring',
                  child: Row(children: [
                    Icon(Icons.repeat),
                    SizedBox(width: 10),
                    Text('Recurring Activities'),
                  ])),
              PopupMenuItem(
                  value: 'display',
                  child: Row(children: [
                    Icon(Icons.palette_outlined),
                    SizedBox(width: 10),
                    Text('Display Settings'),
                  ])),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Log Entry'),
            Tab(text: 'Dashboard'),
          ],
        ),
      ),
      body: _family.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_showInviteBanner) _InviteBanner(
                  onInvite: () {
                    _dismissBanner();
                    _openInvite();
                  },
                  onDismiss: _dismissBanner,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      EntryScreen(
                        family: _family,
                        onEntrySaved: () => SyncService.instance.sync(),
                      ),
                      DashboardScreen(family: _family),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Invite banner ─────────────────────────────────────────

class _InviteBanner extends StatelessWidget {
  final VoidCallback onInvite;
  final VoidCallback onDismiss;
  const _InviteBanner({required this.onInvite, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
        color: c.greenTint,
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(children: [
          const Text('👨‍👩‍👧', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite your partner',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: c.green)),
                Text(
                  'Share this journal across different Apple IDs',
                  style: TextStyle(fontSize: 12, color: c.txt2),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onInvite,
            style: TextButton.styleFrom(foregroundColor: c.green),
            child: const Text('Invite →',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: c.txt2),
            onPressed: onDismiss,
            tooltip: 'Dismiss',
          ),
        ]),
      );
  }
}

// ── Sync status dot ───────────────────────────────────────

/// "just now" / "3m ago" / "2h ago" / "5d ago" — good enough for a tooltip,
/// no need for anything fancier than coarse buckets.
String _relTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class _SyncDot extends StatelessWidget {
  final SyncStatus status;
  const _SyncDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final last = SyncController.instance.lastSyncedAt;
    final tooltip = {
      SyncStatus.syncing: 'Syncing…',
      SyncStatus.synced:
          last != null ? 'CloudKit synced — ${_relTime(last)}' : 'CloudKit synced',
      SyncStatus.error: 'Sync error — will retry',
      SyncStatus.unavailable: 'Sync not available',
      SyncStatus.idle: 'Waiting to sync',
    };
    final color = switch (status) {
      SyncStatus.synced  => const Color(0xFF69F0AE),
      SyncStatus.syncing => const Color(0xFFFFD740),
      SyncStatus.error   => const Color(0xFFFF5252),
      _                  => Colors.white30,
    };

    return Tooltip(
      message: tooltip[status] ?? '',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
        child: status == SyncStatus.syncing
            ? const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFFFD740)),
              )
            : Container(
                width: 10, height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
      ),
    );
  }
}
