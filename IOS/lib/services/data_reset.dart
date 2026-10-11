import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/dashboard_prefs.dart';
import '../notifications/notification_service.dart';
import '../settings/app_settings.dart';
import '../sync/sync_service.dart';

/// Bumped to restart the app's screens from scratch (main.dart keys its
/// router on it): after Delete all data, the app opens at onboarding.
final appGeneration = ValueNotifier<int>(0);

/// Settings › Delete all data. The iCloud copy goes first: if that fails
/// (offline), nothing is deleted, because sync would otherwise restore the
/// log from iCloud. Returns false in that case.
///
/// Doesn't restart the screens itself; the caller bumps [appGeneration]
/// once its dialogs are closed.
Future<bool> deleteAllData() async {
  final sync = SyncService.instance;
  sync.paused = true;
  try {
    if (!await sync.deleteCloudData()) return false;
    // Past this point iCloud is already empty: a failing step must not stop
    // the local delete halfway.
    try {
      await NotificationService.instance.cancelAll();
    } catch (_) {}
    await DatabaseHelper.instance.deleteEverything();
    await AppSettings.instance.reload();
    await DashboardPrefs.instance.load();
    return true;
  } finally {
    sync.paused = false;
  }
}
