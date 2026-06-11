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

  testWidgets('existing family goes straight to home tabs', (tester) async {
    await tester.runAsync(() async {
      await DatabaseHelper.resetForTests();
      await DatabaseHelper.instance.saveFamily(['Mom', 'Dad'], ['Kid']);
    });

    await tester.pumpWidget(const PlaygroundTrackerApp());
    // The DB lives in the real-async zone (opened via runAsync above), so
    // give real time for queries to complete between frame pumps.
    // pumpAndSettle can't be used — it spins forever on the loading spinner.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    expect(find.text('Log Entry'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
