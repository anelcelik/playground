import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../models/family.dart';
import '../theme.dart';
import 'entry_actions.dart';

/// One logged entry: who, when, how long, which kids, activities. Tapping it
/// opens Edit / Delete (entry_actions.dart). Used by Settings › Log.
class EntryRow extends StatelessWidget {
  final Entry entry;
  final Family family;

  /// Runs after an edit or delete, so the list can reload.
  final VoidCallback onChanged;

  const EntryRow({
    super.key,
    required this.entry,
    required this.family,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final e = entry;
    final who = e.userList.isEmpty ? e.user : e.userList.join(' & ');
    final tag = e.noPlayground
        ? 'Nobody went'
        : e.vacation
            ? 'Vacation'
            : (e.shift == 'morning' ? 'Morning' : 'Evening');
    final visit = !e.vacation && !e.noPlayground;
    final detail = <String>[
      if (visit && e.duration != null) e.duration!,
      if (visit && e.kidList.isNotEmpty) e.kidList.join(' & '),
      if (e.noPlayground && (e.excuse?.isNotEmpty ?? false)) e.excuse!,
      if (e.absentNote(family.parents).isNotEmpty) e.absentNote(family.parents),
    ];

    return InkWell(
      onTap: () => showEntryActions(context,
          entry: e, family: family, onChanged: onChanged),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 34,
              margin: const EdgeInsets.only(right: 12, top: 2),
              color: visit ? c.green : c.hairline,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(who,
                      style:
                          AppType.heading.copyWith(color: c.txt, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text([tag, ...detail].join('  ·  '),
                      style: AppType.bodySm.copyWith(color: c.txt2)),
                  if (e.activityList.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final a in e.activityList)
                          Text(a.toUpperCase(),
                              style: AppType.label.copyWith(
                                  color: c.accentTxt,
                                  fontSize: 9,
                                  letterSpacing: 0.9)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: c.txt2),
          ],
        ),
      ),
    );
  }
}
