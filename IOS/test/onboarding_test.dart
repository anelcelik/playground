import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playground_tracker/db/database_helper.dart';
import 'package:playground_tracker/main.dart';
import 'package:playground_tracker/screens/onboarding_screen.dart';
import 'package:playground_tracker/theme.dart';
import 'package:playground_tracker/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // No-isolate variant: the worker-isolate factory deadlocks under
    // flutter_test, which already runs each test in its own isolate.
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseHelper.databasePathOverride = inMemoryDatabasePath;
  });

  // The DB lives in the real-async zone; give it real time between frames,
  // and let page transitions run (pumpAndSettle spins on the loading bar).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('onboarding saves the family and opens the app', (tester) async {
    await tester.runAsync(DatabaseHelper.resetForTests);
    await tester.pumpWidget(const PlaygroundTrackerApp());
    await settle(tester);

    // Block buttons render their labels uppercased.
    await tester.tap(find.text('GET STARTED'));
    await settle(tester);

    expect(find.text('Who takes the kids out?'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Mom');
    await settle(tester);
    await tester.tap(find.text('CONTINUE'));
    await settle(tester);

    expect(find.text('And the kids?'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Bean');
    await settle(tester);
    await tester.tap(find.text('CONTINUE'));
    await settle(tester);

    // Reminders and plans are optional.
    await tester.tap(find.text('SKIP FOR NOW'));
    await settle(tester);
    await tester.tap(find.text('SKIP FOR NOW'));
    await settle(tester);

    await tester.tap(find.text('START USING THE APP'));
    await settle(tester);

    expect(find.text('TODAY'), findsOneWidget);
    final family =
        await tester.runAsync(() => DatabaseHelper.instance.getFamily());
    expect(family!.parents, ['Mom']);
    expect(family.kids, ['Bean']);
  });

  testWidgets('names are required before continuing', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(AppColors.modernistLight),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OnboardingScreen(onComplete: () {}),
    ));
    await tester.pump();

    await tester.tap(find.text('GET STARTED'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('CONTINUE')); // no name typed yet
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Who takes the kids out?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Mom');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('And the kids?'), findsOneWidget);
  });
}
