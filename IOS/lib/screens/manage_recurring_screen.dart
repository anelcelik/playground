import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/family.dart';
import '../models/recurring_activity.dart';
import '../notifications/notification_service.dart';
import 'recurring_activity_form.dart';

import '../settings/app_settings.dart';
import '../theme.dart';

// Brand accent colours — intentionally fixed in both light and dark mode
const _kGreen   = kGreen;
const _kGreenLt = kGreenLt;
const _kAmber   = kAmber;
const _kBlue    = kBlue;
// _kCard / _kBorder / _kTxt / _kTxt2 / _kBg come from AppColors.of(context) per build()



class ManageRecurringScreen extends StatefulWidget {
  const ManageRecurringScreen({super.key});

  @override
  State<ManageRecurringScreen> createState() => _ManageRecurringScreenState();
}

class _ManageRecurringScreenState extends State<ManageRecurringScreen> {
  // Theme-aware colour getters — readable from any method on this State
  Color get _kCard   => AppColors.of(context).card;
  Color get _kBorder => AppColors.of(context).border;
  Color get _kTxt    => AppColors.of(context).txt;
  Color get _kTxt2   => AppColors.of(context).txt2;
  Color get _kBg     => AppColors.of(context).bg;

  List<RecurringActivity> _activities = [];
  Family _family = const Family(parents: [], kids: []);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final activities = await DatabaseHelper.instance.getAllRecurringActivities();
    final family = await DatabaseHelper.instance.getFamily();
    if (mounted) {
      setState(() {
        _activities = activities;
        _family = family;
        _loading = false;
      });
    }
  }

  Future<void> _openForm([RecurringActivity? existing]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecurringActivityForm(
          family: _family,
          existing: existing,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _delete(RecurringActivity a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete activity?'),
        content: Text(
            '"${a.title}" and all its logs will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteRecurringActivity(a.id);
      await NotificationService.instance.cancelRecurringActivity(a);
      _load();
    }
  }

  Future<void> _toggleActive(RecurringActivity a) async {
    final updated = a.copyWith(isActive: !a.isActive);
    await DatabaseHelper.instance.upsertRecurringActivity(updated);
    if (!updated.isActive) {
      await NotificationService.instance.cancelRecurringActivity(updated);
    } else if (updated.notifyEnabled) {
      await NotificationService.instance.scheduleRecurringActivity(updated);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final _appC = AppColors.of(context);
    final _kCard   = _appC.card;
    final _kBorder = _appC.border;
    final _kTxt    = _appC.txt;
    final _kTxt2   = _appC.txt2;
    final _kBg     = _appC.bg;



    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kGreen,
        title: Text('🔁 Recurring Activities',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: Icon(Icons.add),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? _EmptyState(onAdd: () => _openForm())
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _activities.length,
                  itemBuilder: (_, i) => _ActivityTile(
                    activity: _activities[i],
                    onEdit: () => _openForm(_activities[i]),
                    onDelete: () => _delete(_activities[i]),
                    onToggleActive: () => _toggleActive(_activities[i]),
                  ),
                ),
    );
  }
}

// ── Activity tile ─────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  final RecurringActivity activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _ActivityTile({
    required this.activity,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final _appC = AppColors.of(context);
    final _kCard   = _appC.card;
    final _kBorder = _appC.border;
    final _kTxt    = _appC.txt;
    final _kTxt2   = _appC.txt2;
    final _kBg     = _appC.bg;



    final a = activity;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))
        ],
      ),
      child: Column(children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(children: [
            Expanded(
              child: Text(a.title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: a.isActive ? _kTxt : _kTxt2)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: a.isActive
                    ? const Color(0xFFEDF7ED)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                a.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: a.isActive ? _kGreen : _kTxt2),
              ),
            ),
          ]),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('🔁 ${a.repeatDaysLabel}',
                  style: TextStyle(fontSize: 13, color: _kTxt2)),
              if (a.kidNames.isNotEmpty)
                Text('👧 ${a.kidNames.join(', ')}',
                    style: TextStyle(fontSize: 13, color: _kTxt2)),
              if (a.dateFrom != null || a.dateTo != null)
                Text(
                  '📅 ${a.dateFrom ?? '…'} → ${a.dateTo ?? '…'}',
                  style: TextStyle(fontSize: 12, color: _kTxt2),
                ),
              if (a.notifyEnabled && a.notifyHour != null)
                Text('🔔 ${a.notifyTimeLabel}',
                    style: TextStyle(fontSize: 12, color: _kTxt2)),
            ],
          ),
          onTap: onEdit,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        Row(children: [
          _TileAction(
              icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
          _TileAction(
            icon: a.isActive
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            label: a.isActive ? 'Deactivate' : 'Activate',
            onTap: onToggleActive,
          ),
          _TileAction(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: Colors.red,
              onTap: onDelete),
        ]),
      ]),
    );
  }
}

class _TileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _TileAction(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final _kTxt2 = AppColors.of(context).txt2;
    return Expanded(
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 16, color: color ?? _kTxt2),
          label: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color ?? _kTxt2,
                  fontWeight: FontWeight.w500)),
          style: TextButton.styleFrom(padding: const EdgeInsets.all(10)),
        ),
      );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final _kTxt  = AppColors.of(context).txt;
    final _kTxt2 = AppColors.of(context).txt2;
    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔁', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No recurring activities yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _kTxt)),
            const SizedBox(height: 6),
            Text(
                'Add activities that repeat on specific days\nand they\'ll appear in the daily log.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _kTxt2)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add),
              label: Text('Add first activity'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
    );
  }
}
