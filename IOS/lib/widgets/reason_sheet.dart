import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../theme.dart';
import 'modernist.dart';

const _kDefaultReasons = ['Rain', 'Sick', 'Too late', 'Busy'];

/// "Why not?" sheet for a nobody-went day — shared by Today and the entry
/// Edit/Delete sheet. Returns the chosen or typed reason, null on dismiss.
/// A typed reason is remembered as an excuse tag so it is a chip next time.
Future<String?> showReasonSheet(BuildContext context) async {
  final tags = await DatabaseHelper.instance.getTags('excuse');
  if (!context.mounted) return null;
  final reason = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) {
      final c = AppColors.of(ctx);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Rule(),
            const SectionLabel('Why not?'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in {..._kDefaultReasons, ...tags})
                    SquareChip(label: t, onTap: () => Navigator.pop(ctx, t)),
                  SquareChip(
                    label: '+ Write your own',
                    onTap: () async {
                      final typed = await _typeReason(ctx);
                      if (typed != null && ctx.mounted) {
                        Navigator.pop(ctx, typed);
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                  'Pick or write a reason to save the day as “nobody went”.',
                  style: AppType.bodySm.copyWith(color: c.txt2)),
            ),
          ],
        ),
      );
    },
  );
  if (reason != null && !_kDefaultReasons.contains(reason)) {
    await DatabaseHelper.instance.addTag('excuse', reason);
  }
  return reason;
}

Future<String?> _typeReason(BuildContext context) async {
  final ctrl = TextEditingController();
  // Commas would split one reason into several in History's reason counts.
  String clean(String v) => v.replaceAll(',', ' ').trim();
  final value = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Why not?',
          style: AppType.heading.copyWith(color: AppColors.of(ctx).txt)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'e.g. Grandma visiting'),
        onSubmitted: (v) => Navigator.pop(ctx, clean(v)),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, clean(ctrl.text)),
            child: const Text('SAVE')),
      ],
    ),
  );
  return value == null || value.isEmpty ? null : value;
}
