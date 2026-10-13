import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/modernist.dart';
import '../l10n/l10n.dart';
import '../settings/app_settings.dart';

/// The privacy policy, readable inside the app (App Review guideline
/// 5.1.1(i) asks for it in the app as well as in App Store Connect).
/// The same text lives in webpagepreparation/privacy-policy.md for the web
/// page; change both together.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const effective = '2026-10-11';

  /// Heading and text of each section, in the current language.
  static List<(String, String)> sections(AppLocalizations l) => [
        (l.privInShortTitle, l.privInShort),
        (l.privStoresTitle, l.privStores),
        (l.privICloudTitle, l.privICloud),
        (l.privRemindersTitle, l.privReminders),
        (l.privCalendarTitle, l.privCalendar),
        (l.privChildrenTitle, l.privChildren),
        (l.privDeletingTitle, l.privDeleting),
        (l.privChangesTitle, l.privChanges),
      ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(context.l10n.privacy,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
                context.l10n.privacyEffective(
                    AppSettings.instance.fmtDate(effective)),
                style: AppType.bodySm.copyWith(color: c.txt2)),
          ),
          for (final (heading, body) in sections(context.l10n)) ...[
            SectionLabel(heading),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(body,
                  style: AppType.body.copyWith(color: c.txt, height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }
}
