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
import 'settings/app_settings.dart';
import 'sync/sync_controller.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite needs FFI on Linux / macOS / Windows desktop
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Timezone setup — required for scheduling notifications at local time
  // flutter_timezone 5.x returns TimezoneInfo; .name gives the IANA string.
  tz.initializeTimeZones();
  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz_local.setLocalLocation(tz_local.getLocation(tzInfo.identifier));
  } catch (_) {
    // Falls back to UTC if timezone detection fails
  }

  // Load display preferences (date/time format) + dashboard layout
  await AppSettings.instance.load();
  await DashboardPrefs.instance.load();

  // Local notifications (no-op on unsupported platforms)
  await NotificationService.instance.init();

  // iCloud sync (no-op on non-iOS platforms)
  SyncController.instance.start();

  runApp(const PlaygroundTrackerApp());
}

class PlaygroundTrackerApp extends StatelessWidget {
  const PlaygroundTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder rebuilds MaterialApp whenever AppSettings changes —
    // this is how dark mode / theme switches propagate to the whole tree.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (_, __) => MaterialApp(
        title: 'Playground Tracker',
        debugShowCheckedModeBanner: false,
        theme: kLightTheme,
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_hasFamily) {
      return SetupScreen(
        onComplete: () => setState(() => _hasFamily = true),
      );
    }
    return const HomeScreen();
  }
}
