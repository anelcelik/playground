import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/modernist.dart';

/// The privacy policy, readable inside the app (App Review guideline
/// 5.1.1(i) asks for it in the app as well as in App Store Connect).
/// The same text lives in docs/privacy-policy.md for the web page; change
/// both together.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const effective = '9 October 2026';

  static const sections = <(String, String)>[
    (
      'In short',
      'Playground Tracker does not collect personal data. There is no '
          'account, no server of ours, no analytics, no advertising and no '
          'tracking. The developer cannot see your log.',
    ),
    (
      'What the app stores',
      'The names of the parents and kids you enter, your visits (date, '
          'morning or evening, who went, which kids, how long, activities, '
          'and any reason you give), your plans and how they went, and your '
          'settings. All of it is kept in the app\'s private storage on your '
          'iPhone.',
    ),
    (
      'iCloud sync and family sharing',
      'If you are signed in to iCloud, the app keeps a copy in your own '
          'private iCloud database through Apple\'s CloudKit, so it stays in '
          'sync across your devices. If you invite family members with a '
          'share link, the people you invite can see and edit the shared log '
          'until you stop sharing. iCloud data is handled by Apple under '
          'Apple\'s privacy policy; the developer has no access to it.',
    ),
    (
      'Reminders',
      'Reminder notifications are scheduled on your iPhone. Nothing about '
          'them is sent anywhere. The app asks for permission only when you '
          'turn a reminder on.',
    ),
    (
      'Calendar',
      'Add to Calendar opens Apple\'s own event editor with the plan filled '
          'in. The app does not read your calendar; the event is saved only '
          'if you tap Add.',
    ),
    (
      'Children',
      'The app is meant for parents. Children\'s names stay on your iPhone '
          'and in your own iCloud. Nothing about children is sent to the '
          'developer or to anyone else.',
    ),
    (
      'Deleting your data',
      'Delete entries in the app at any time. Deleting the app removes '
          'everything stored on the iPhone. To remove the iCloud copy, open '
          'iOS Settings, tap your name, then iCloud, open the storage list, '
          'choose Playground Tracker and delete its data. To stop sharing, '
          'use Family sync in Settings.',
    ),
    (
      'Changes',
      'If this policy changes, the new version ships with an app update and '
          'its effective date changes above.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('Privacy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text('Effective $effective',
                style: AppType.bodySm.copyWith(color: c.txt2)),
          ),
          for (final (heading, body) in sections) ...[
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
