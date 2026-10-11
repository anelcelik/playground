import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playground_tracker/db/database_helper.dart';
import 'package:playground_tracker/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // No-isolate variant: the worker-isolate factory deadlocks under
    // flutter_test, which already runs each test in its own isolate.
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseHelper.databasePathOverride = inMemoryDatabasePath;
  });

  // NOTE: all direct DB work must go through tester.runAsync — testWidgets
  // bodies run in a fake-async zone where real async DB futures never
  // complete. The app's own DB calls complete during pump, which flushes
  // microtasks.

  testWidgets('fresh install starts onboarding', (tester) async {
    await tester.runAsync(DatabaseHelper.resetForTests);

    await tester.pumpWidget(const PlaygroundTrackerApp());
    await tester.pumpAndSettle();

    // No family configured yet → onboarding, not the home tabs
    expect(find.textContaining('Playground Tracker'), findsWidgets);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
