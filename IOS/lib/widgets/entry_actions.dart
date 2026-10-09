import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../screens/edit_entry_screen.dart';
import '../settings/app_settings.dart';
import 'reason_sheet.dart';

/// Edit/Delete bottom sheet for a log entry — shared by Today's Log and
/// the dashboard log. Vacation entries have nothing meaningful to edit, so
/// they only get Delete; no-playground entries can change their reason.
///
/// [onChanged] runs after a successful edit or delete; callers use it to
/// reload their lists and trigger a sync.
Future<void> showEntryActions(
  BuildContext context, {
  required Entry entry,
  required Family family,
  required VoidCallback onChanged,
}) async {
  final canEdit = !entry.vacation && !entry.noPlayground;

  final action = await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit entry'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
          if (entry.noPlayground)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Change reason'),
              onTap: () => Navigator.pop(ctx, 'reason'),
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete entry',
                style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pop(ctx, 'delete'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  if (action == 'edit') {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEntryScreen(
          entry: entry,
          family: family,
          onSaved: onChanged,
        ),
      ),
    );
    return;
  }

  if (action == 'reason') {
    final reason = await showReasonSheet(context);
    if (reason == null) return;
    await DatabaseHelper.instance.updateEntry(entry.copyWith(excuse: reason));
    onChanged();
    return;
  }

  // Delete — confirm first; the soft delete propagates via sync.
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete entry?'),
      content: Text(
          '${AppSettings.instance.fmtDateFull(entry.date)} — this also '
          'removes it on synced devices.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (ok != true || entry.id == null) return;
  await DatabaseHelper.instance.deleteEntry(entry.id!);
  onChanged();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text('Entry deleted'),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 4),
    // Flutter keeps a snack bar with an action up until it is tapped unless
    // told otherwise — the Undo bar would never go away on its own.
    persist: false,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () async {
        await DatabaseHelper.instance.restoreEntry(entry.id!);
        onChanged();
      },
    ),
  ));
}
