import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../theme.dart';
import 'modernist.dart';

const kDefaultReasons = ['Rain', 'Sick', 'Too late', 'Busy'];

/// Reason picker sheet — "Why not?" for a nobody-went day (Today and the
/// entry Edit/Delete sheet) and "Why skip?" for a planned activity.
/// Returns the chosen or typed reason, null on dismiss. A typed reason is
/// remembered as an excuse tag so it is a chip next time.
Future<String?> showReasonSheet(
  BuildContext context, {
  String title = 'Why not?',
  String hint = 'Pick or write a reason to save the day as “nobody went”.',
}) async {
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
            SectionLabel(title),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in {...kDefaultReasons, ...tags})
                    SquareChip(label: t, onTap: () => Navigator.pop(ctx, t)),
                  SquareChip(
                    label: '+ Write your own',
                    onTap: () async {
                      final typed = await typeReason(ctx, title: title);
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
              child: Text(hint, style: AppType.bodySm.copyWith(color: c.txt2)),
            ),
          ],
        ),
      );
    },
  );
  await rememberReason(reason);
  return reason;
}

/// Saves a typed reason as an excuse tag; the built-in ones need no tag.
Future<void> rememberReason(String? reason) async {
  if (reason != null && !kDefaultReasons.contains(reason)) {
    await DatabaseHelper.instance.addTag('excuse', reason);
  }
}

/// Free-text reason dialog. Null when cancelled or left empty.
Future<String?> typeReason(BuildContext context, {String title = 'Why not?'}) async {
  final ctrl = TextEditingController();
  // Commas would split one reason into several in History's reason counts.
  String clean(String v) => v.replaceAll(',', ' ').trim();
  final value = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title,
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

/// Inline single-choice reason chips with "+ Write your own" — for "why
/// didn't the other parent go?" inside the visit sheet and Edit Entry.
/// Tapping the selected chip again clears it (the reason is optional).
class ReasonChips extends StatefulWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  final String dialogTitle;

  const ReasonChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.dialogTitle = 'Why not?',
  });

  @override
  State<ReasonChips> createState() => _ReasonChipsState();
}

class _ReasonChipsState extends State<ReasonChips> {
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.getTags('excuse').then((t) {
      if (mounted) setState(() => _tags = t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in {...kDefaultReasons, ..._tags, if (sel != null) sel})
          SquareChip(
            label: t,
            small: true,
            selected: t == sel,
            onTap: () => widget.onChanged(t == sel ? null : t),
          ),
        SquareChip(
          label: '+ Write your own',
          small: true,
          onTap: () async {
            final typed = await typeReason(context, title: widget.dialogTitle);
            if (typed != null) widget.onChanged(typed);
          },
        ),
      ],
    );
  }
}
