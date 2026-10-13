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
import 'log_screen.dart';
import 'privacy_screen.dart';
import 'recap_screen.dart';
import '../l10n/l10n.dart';
import '../settings/app_settings.dart';

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
          child: Text(context.l10n.settings,
              style: AppType.title.copyWith(color: c.txt)),
        ),
        const Rule(),
        SectionLabel(context.l10n.family),
        _Row(
          label: context.l10n.parentsAndKids,
          value: '${context.l10n.parentsCount(family.parents.length)} · '
              '${context.l10n.kidsCount(family.kids.length)}',
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
          label: context.l10n.familySync,
          value: context.l10n.familySyncSub,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const InviteFamilyScreen())),
        ),
        const Rule(),
        SectionLabel(context.l10n.app),
        _Row(
          label: context.l10n.remindersSetting,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        _Row(
          label: context.l10n.languageDateTheme,
          value: AppSettings.languageNames[AppSettings.instance.locale.languageCode]!,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DisplaySettingsScreen())),
        ),
        _Row(
          label: context.l10n.recap,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RecapScreen())),
        ),
        _Row(
          label: context.l10n.privacy,
          value: context.l10n.noDataCollected,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PrivacyScreen())),
        ),
        const Rule(),
        SectionLabel(context.l10n.yourData),
        _Row(
          label: context.l10n.log,
          value: context.l10n.logSub,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => LogScreen(family: family))),
        ),
        _Row(
          label: context.l10n.deleteAllData,
          value: context.l10n.deleteAllDataSub,
          onTap: () => _confirmDeleteAll(context),
        ),
        const Rule(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Text(
              context.l10n.aboutNote,
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
      title: Text(ctx.l10n.deleteAllDataQuestion),
      content: Text(ctx.l10n.deleteAllDataBody),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel)),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.deleteEverything,
                style: const TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      content: Row(
        children: [
          const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 16),
          Text(ctx.l10n.deleting),
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
      title: Text(ctx.l10n.nothingDeleted),
      content: Text(ctx.l10n.nothingDeletedBody),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: Text(ctx.l10n.ok)),
      ],
    ),
  );
}
