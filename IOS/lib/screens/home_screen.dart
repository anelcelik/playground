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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadFamily();
    // Auto-mark any unresolved past activities as missed
    RecurringService.instance.autoMarkMissed();
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
            // Push updated family config to iCloud immediately
            SyncService.instance.sync();
          },
        ),
      ),
    );
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
              MaterialPageRoute(
                  builder: (_) => const NotificationsScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            tooltip: 'Settings',
            onSelected: (v) {
              if (v == 'family') _openSettings();
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
          : TabBarView(
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
    );
  }
}

// ── Sync status indicator ─────────────────────────────────

class _SyncDot extends StatelessWidget {
  final SyncStatus status;
  const _SyncDot({required this.status});

  @override
  Widget build(BuildContext context) {
    const tooltip = {
      SyncStatus.syncing: 'Syncing…',
      SyncStatus.synced: 'iCloud synced',
      SyncStatus.error: 'Sync error — will retry',
      SyncStatus.unavailable: 'iCloud unavailable',
      SyncStatus.idle: 'Waiting to sync',
    };
    final color = switch (status) {
      SyncStatus.synced => const Color(0xFF69F0AE),
      SyncStatus.syncing => const Color(0xFFFFD740),
      SyncStatus.error => const Color(0xFFFF5252),
      _ => Colors.white30,
    };

    return Tooltip(
      message: tooltip[status] ?? '',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
        child: status == SyncStatus.syncing
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFFFD740)),
              )
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
      ),
    );
  }
}
