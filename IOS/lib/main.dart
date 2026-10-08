import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz_local;

import 'db/database_helper.dart';
import 'models/dashboard_prefs.dart';
import 'notifications/notification_service.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';
import 'services/diag_log.dart';
import 'services/quick_action_service.dart';
import 'settings/app_settings.dart';
import 'sync/sync_controller.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DiagLog.instance.attach();
  DiagLog.instance.log('main() start');

  // sqflite needs FFI on Linux / macOS / Windows desktop
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Nothing below may keep runApp() from running. iOS can reclaim a
  // backgrounded app's scene, which destroys this engine; reopening starts a
  // fresh engine and runs main() again inside the still-running process.
  // A step that threw or never answered then left the white launch screen
  // up for good. Each step is bounded and logged (DiagLog) so a slow or
  // failing one degrades to defaults instead.

  // Timezone setup — required for scheduling notifications at local time
  tz.initializeTimeZones();
  await _startupStep('timezone', () async {
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz_local.setLocalLocation(tz_local.getLocation(localTz));
  }); // falls back to UTC (e.g. on Linux desktop)

  // Load display preferences (date/time format) + dashboard layout
  await _startupStep('settings', AppSettings.instance.load);
  await _startupStep('dashboard prefs', DashboardPrefs.instance.load);

  // Local notifications (no-op on unsupported platforms)
  await _startupStep('notifications', NotificationService.instance.init);

  // The app is paid up front on the App Store, so there is no in-app
  // purchase to restore and no unlock state to hold. StoreKit gates the
  // download; the app itself never gates a screen. PurchaseService and
  // PaywallScreen are deliberately no longer wired in.

  // iCloud sync (no-op on non-iOS platforms)
  SyncController.instance.start();

  // Home Screen long-press shortcuts ("Log a Visit" / "View Dashboard")
  await _startupStep('quick actions', QuickActionService.instance.init);

  DiagLog.instance.log('startup: runApp');
  runApp(const PlaygroundTrackerApp());
}

/// Runs one startup step with a time limit; a failure is logged, not fatal.
Future<void> _startupStep(String name, Future<void> Function() run) async {
  try {
    await run().timeout(const Duration(seconds: 8));
    DiagLog.instance.log('startup: $name ok');
  } catch (e, st) {
    DiagLog.instance.log('startup: $name FAILED: $e\n$st');
  }
}

class PlaygroundTrackerApp extends StatelessWidget {
  const PlaygroundTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder rebuilds MaterialApp whenever AppSettings changes —
    // this is how the theme-mode switch propagates to the whole tree.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (_, __) => MaterialApp(
        title: 'Playground Tracker',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(AppSettings.instance.palette, Brightness.light),
        darkTheme: buildTheme(AppSettings.instance.palette, Brightness.dark),
        themeMode: AppSettings.instance.themeMode,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  bool _loading = true;
  bool _hasFamily = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final family = await DatabaseHelper.instance.getFamily();
    if (mounted) {
      setState(() {
        _hasFamily = family.parents.isNotEmpty;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // A bare 2px accent bar rather than a spinner — the first frame the
      // user ever sees should already look like the app.
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: AppColors.of(context).hairline,
              color: AppColors.of(context).green,
            ),
          ),
        ),
      );
    }
    if (!_hasFamily) {
      return SetupScreen(
        onComplete: () => setState(() => _hasFamily = true),
      );
    }
    return const HomeScreen();
  }
}
