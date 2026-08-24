import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz_local;

import 'db/database_helper.dart';
import 'models/dashboard_prefs.dart';
import 'notifications/notification_service.dart';
import 'purchase/purchase_service.dart';
import 'screens/paywall_screen.dart';
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

  // Timezone setup — required for scheduling notifications at local time
  tz.initializeTimeZones();
  try {
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz_local.setLocalLocation(tz_local.getLocation(localTz));
  } catch (_) {
    // Falls back to UTC if timezone detection fails (e.g. on Linux desktop)
  }

  // Load display preferences (date/time format) + dashboard layout
  await AppSettings.instance.load();
  await DashboardPrefs.instance.load();

  // Local notifications (no-op on unsupported platforms)
  await NotificationService.instance.init();

  // One-time $0.99 unlock (no-op / always-unlocked on non-iOS platforms)
  await PurchaseService.instance.init();

  // iCloud sync (no-op on non-iOS platforms)
  SyncController.instance.start();

  // Home Screen long-press shortcuts ("Log a Visit" / "View Dashboard")
  await QuickActionService.instance.init();

  runApp(const PlaygroundTrackerApp());
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
    PurchaseService.instance.addListener(_onPurchaseChanged);
    _check();
  }

  @override
  void dispose() {
    PurchaseService.instance.removeListener(_onPurchaseChanged);
    super.dispose();
  }

  void _onPurchaseChanged() {
    if (mounted) setState(() {});
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
    // Paywall comes first — nothing past this point without the $0.99 unlock.
    if (!PurchaseService.instance.isPurchased) {
      return const PaywallScreen();
    }
    if (!_hasFamily) {
      return SetupScreen(
        onComplete: () => setState(() => _hasFamily = true),
      );
    }
    return const HomeScreen();
  }
}
