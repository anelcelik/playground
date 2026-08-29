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
import 'services/quick_action_service.dart';
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

  tz.initializeTimeZones();
  try {
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz_local.setLocalLocation(tz_local.getLocation(localTz));
  } catch (_) {
    // Falls back to UTC if timezone detection fails (e.g. on Linux desktop)
  }

  await AppSettings.instance.load();
  await DashboardPrefs.instance.load();
  await NotificationService.instance.init();

  // NOTE: PurchaseService is gone. The app is a paid-up-front App Store
  // download, so StoreKit gates the install — there is nothing to unlock
  // in-app, no receipt to check, and no paywall to show.

  SyncController.instance.start();
  await QuickActionService.instance.init();

  runApp(const PlaygroundTrackerApp());
}

class PlaygroundTrackerApp extends StatelessWidget {
  const PlaygroundTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (_, __) => MaterialApp(
        title: 'Playground Tracker',
        debugShowCheckedModeBanner: false,
        theme: kLightTheme,
        darkTheme: kDarkTheme,
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
      return const Scaffold(
        body: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: kAccent),
          ),
        ),
      );
    }
    if (!_hasFamily) {
      return SetupScreen(onComplete: () => setState(() => _hasFamily = true));
    }
    return const HomeScreen();
  }
}
