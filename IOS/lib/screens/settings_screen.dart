import 'package:flutter/material.dart';

import '../models/family.dart';
import '../services/data_reset.dart';
import '../sync/sync_service.dart';
import '../theme.dart';
import '../widgets/modernist.dart';
import 'setup_screen.dart';
import 'invite_family_screen.dart';
import 'notifications_screen.dart';
import 'display_settings_screen.dart';
import 'privacy_screen.dart';
import 'recap_screen.dart';

/// The fourth tab. Collects what the gear PopupMenuButton used to hold,
/// minus Recap (now on Today) and Recurring Activities (now the Plans tab).
class SettingsScreen extends StatelessWidget {
  final Family family;
  final VoidCallback onFamilyChanged;

  const SettingsScreen({
    super.key,
    required this.family,
    required this.onFamilyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
          child: Text('Settings', style: AppType.title.copyWith(color: c.txt)),
        ),
        const Rule(),
        const SectionLabel('Family'),
        _Row(
          label: 'Parents & kids',
          value: '${family.parents.length} parents · ${family.kids.length} kids',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SetupScreen(
                isEditing: true,
                initialParents: family.parents,
                initialKids: family.kids,
                onComplete: () {
                  Navigator.pop(context);
                  onFamilyChanged();
                  SyncService.instance.sync();
                },
              ),
            ),
          ),
        ),
        _Row(
          label: 'Family sync',
          value: 'Share across Apple IDs',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const InviteFamilyScreen())),
        ),
        const Rule(),
        const SectionLabel('App'),
        _Row(
          label: 'Reminders',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        _Row(
          label: 'Date, time & theme',
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DisplaySettingsScreen())),
        ),
        _Row(
          label: 'Recap',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RecapScreen())),
        ),
        _Row(
          label: 'Privacy',
          value: 'No data collected',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PrivacyScreen())),
        ),
        const Rule(),
        const SectionLabel('Your data'),
        _Row(
          label: 'Delete all data',
          value: 'On this iPhone and in iCloud',
          onTap: () => _confirmDeleteAll(context),
        ),
        const Rule(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Text(
              'Playground Tracker — a one-time App Store purchase. '
              'No subscription, no account, no ads. Your log stays on your '
              'devices and syncs through your own iCloud.',
              style: AppType.bodySm.copyWith(color: c.txt2, height: 1.5)),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _Row({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          const Hairline(),
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label,
                          style: AppType.body.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: c.txt)),
                      if (value != null) ...[
                        const SizedBox(height: 2),
                        Text(value!,
                            style: AppType.bodySm.copyWith(color: c.txt2)),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: c.txt2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings › Delete all data: confirm, delete (iCloud first), then restart
/// the app at onboarding. If iCloud can't be reached nothing is deleted,
/// since sync would bring the log straight back.
Future<void> _confirmDeleteAll(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete all data?'),
      content: const Text(
          'Every visit, plan, name and setting is deleted from this iPhone '
          'and from your iCloud. If you share the log with family, they lose '
          'it too. This can\'t be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything',
                style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 16),
          Text('Deleting\u2026'),
        ],
      ),
    ),
  );
  final deleted = await deleteAllData();
  navigator.pop(); // the progress dialog

  if (deleted) {
    appGeneration.value++; // back to onboarding
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nothing was deleted'),
      content: const Text(
          'iCloud couldn\'t be reached, so your data was left as it is '
          '(otherwise sync would bring it back). Try again when you\'re '
          'online.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
      ],
    ),
  );
}
