import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/family.dart';
import '../sync/sync_controller.dart';
import '../sync/sync_service.dart';
import '../services/recurring_service.dart';
import 'setup_screen.dart';
import 'entry_screen.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';
import 'manage_recurring_screen.dart';
import 'display_settings_screen.dart';
import 'invite_family_screen.dart';

const _kGreen = Color(0xFF2e7d32);

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
    _tabs = TabController(length: 2, vsync: this);
    _loadFamily();
    RecurringService.instance.autoMarkMissed();
    _checkInviteBanner();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: _kGreen,
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
            },
            itemBuilder: (_) => const [
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
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFEDF7ED),
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(children: [
          const Text('👨‍👩‍👧', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invite your partner',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _kGreen)),
                const Text(
                  'Share this journal across different Apple IDs',
                  style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onInvite,
            style: TextButton.styleFrom(foregroundColor: _kGreen),
            child: const Text('Invite →',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF888888)),
            onPressed: onDismiss,
            tooltip: 'Dismiss',
          ),
        ]),
      );
}

// ── Sync status dot ───────────────────────────────────────

class _SyncDot extends StatelessWidget {
  final SyncStatus status;
  const _SyncDot({required this.status});

  @override
  Widget build(BuildContext context) {
    const tooltip = {
      SyncStatus.syncing: 'Syncing…',
      SyncStatus.synced: 'CloudKit synced',
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
