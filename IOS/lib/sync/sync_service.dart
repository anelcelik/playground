import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/recurring_activity.dart';
import '../notifications/notification_service.dart';

// ── Channel ───────────────────────────────────────────────
// Matches the channel name registered in CloudKitPlugin.swift
const _kChannel = MethodChannel('com.playground.tracker/cloudkit');

// A hung native call must never wedge the sync state machine.
const _kCallTimeout = Duration(seconds: 90);

enum SyncStatus { idle, syncing, synced, error, unavailable }

class SyncService {
  static final SyncService instance = SyncService._();

  SyncService._() {
    // Native side calls 'remoteChange' when a CloudKit silent push arrives
    // or right after this device accepts a share — sync immediately.
    _kChannel.setMethodCallHandler((call) async {
      if (call.method == 'remoteChange') sync();
    });
  }

  final ValueNotifier<SyncStatus> status =
      ValueNotifier(SyncStatus.unavailable);

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Counts up whenever a sync brought in something from iCloud (a visit
  /// from the other phone, new names). Screens listen and reload.
  final ValueNotifier<int> dataVersion = ValueNotifier(0);

  /// A sync was asked for while one was running: run once more after it, so
  /// a change push or an accepted invitation is never dropped.
  bool _again = false;

  /// Set while all data is being deleted, so no sync recreates the iCloud
  /// copy between deleting it and wiping the local database.
  bool paused = false;

  bool get _isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  // ── Full sync cycle ───────────────────────────────────

  /// Called periodically, on app foreground, and on remote-change pushes.
  /// 1. Fetches delta changes from CloudKit and merges them into SQLite
  ///    (merge first, so we never overwrite newer remote data with stale local).
  /// 2. Pushes only records modified since the last successful push
  ///    (needs_push flag), batched into a single native call.
  Future<void> sync() async {
    if (!_isIos) {
      status.value = SyncStatus.unavailable;
      return;
    }
    if (paused) return;
    if (status.value == SyncStatus.syncing) {
      _again = true;
      return;
    }
    status.value = SyncStatus.syncing;

    try {
      await _fetchAndMerge().timeout(_kCallTimeout);
      await _push().timeout(_kCallTimeout);
      _lastSyncedAt = DateTime.now();
      status.value = SyncStatus.synced;
      _ensureSubscriptions();
    } on MissingPluginException {
      // Native side skipped CloudKit: this build has no iCloud entitlement
      // (see CloudKitPlugin.isAvailable).
      status.value = SyncStatus.unavailable;
    } on PlatformException catch (e, st) {
      if (e.code == 'ICLOUD_UNAVAILABLE') {
        // Not signed in to iCloud: the app simply works on this iPhone
        // alone. Not an error worth a warning dot.
        status.value = SyncStatus.unavailable;
      } else {
        debugPrint('[CloudKit] sync error: $e\n$st');
        status.value = SyncStatus.error;
      }
    } catch (e, st) {
      debugPrint('[CloudKit] sync error: $e\n$st');
      status.value = SyncStatus.error;
    }

    if (_again) {
      _again = false;
      await sync();
    }
  }

  /// Push a single entry immediately after save / soft-delete.
  /// Silent — does not change the status dot. On failure the entry keeps its
  /// needs_push flag and is retried on the next sync cycle.
  Future<void> pushEntry(Entry entry) async {
    if (!_isIos || paused) return;
    try {
      await _kChannel
          .invokeMethod<void>('saveEntry', entry.toJsonMap())
          .timeout(_kCallTimeout);
      await DatabaseHelper.instance
          .markEntriesPushed([(uuid: entry.uuid, lastModified: entry.lastModified)]);
    } catch (e) {
      debugPrint('[CloudKit] pushEntry error: $e');
    }
  }

  /// Settings › Delete all data: deletes this family's iCloud copy so sync
  /// can't bring it back. True when it is gone or there is none to reach
  /// (not iOS, a build without iCloud, signed out of iCloud); false when the
  /// delete failed, e.g. offline — then nothing should be deleted locally.
  Future<bool> deleteCloudData() async {
    if (!_isIos) return true;
    try {
      await _kChannel.invokeMethod<void>('deleteAllData').timeout(_kCallTimeout);
      _lastSyncedAt = null;
      return true;
    } on MissingPluginException {
      return true;
    } on PlatformException catch (e) {
      return e.code == 'ICLOUD_UNAVAILABLE';
    } catch (_) {
      return false;
    }
  }

  // ── Family sharing ───────────────────────────────────

  /// Opens the native iOS UICloudSharingController.
  /// Shows current participants, lets owner invite via Messages / WhatsApp /
  /// copy link, and revoke access — all in Apple's own UI.
  /// Null when the sheet opened; otherwise why not: 'ICLOUD_UNAVAILABLE'
  /// (not signed in to iCloud), 'UNAVAILABLE' (not an iPhone, or a build
  /// without iCloud) or another error code (offline, …).
  Future<String?> openShareSheet() async {
    if (!_isIos) return 'UNAVAILABLE';
    try {
      await _kChannel
          .invokeMethod<void>('openShareSheet')
          .timeout(_kCallTimeout);
      return null;
    } on MissingPluginException {
      return 'UNAVAILABLE';
    } on PlatformException catch (e) {
      debugPrint('[CloudKit] openShareSheet error: $e');
      return e.code;
    } catch (e) {
      debugPrint('[CloudKit] openShareSheet error: $e');
      return 'ERROR';
    }
  }

  /// Returns the list of connected participants.
  /// Each map: {name, email, role ('owner'|'participant'), status ('accepted'|'pending')}
  Future<List<Map<String, dynamic>>> getParticipants() async {
    if (!_isIos) return [];
    try {
      final raw = await _kChannel.invokeMethod<List>('getParticipants');
      return raw?.cast<Map<Object?, Object?>>()
              .map((m) => m.cast<String, dynamic>())
              .toList() ??
          [];
    } catch (e) {
      debugPrint('[CloudKit] getParticipants error: $e');
      return [];
    }
  }

  /// Removes a participant from the CloudKit share.
  /// [participantRecordName] comes from the `id` field returned by getParticipants().
  Future<bool> revokeParticipant(String participantRecordName) async {
    if (!_isIos) return false;
    try {
      await _kChannel.invokeMethod<void>(
          'revokeParticipant', participantRecordName);
      return true;
    } catch (e) {
      debugPrint('[CloudKit] revokeParticipant error: $e');
      return false;
    }
  }

  /// Returns the iCloud share URL string, or null on error.
  /// Owner calls this once and sends the link via WhatsApp / iMessage.
  /// Partner taps the link → iOS handles the accept flow automatically.
  Future<String?> createShareLink() async {
    if (!_isIos) return null;
    try {
      return await _kChannel.invokeMethod<String>('createShareLink');
    } catch (e) {
      debugPrint('[CloudKit] createShareLink error: $e');
      return null;
    }
  }

  // ── Private helpers ───────────────────────────────────

  Future<void> _push() async {
    final db = DatabaseHelper.instance;

    // Family config + tags — only when changed since the last push
    if (await db.isConfigDirty()) {
      final config = await db.exportConfig();
      await _kChannel.invokeMethod<void>('saveConfig', config);
      await db.markConfigPushed();
    }

    // Entries — only the ones modified since their last successful push,
    // all in one batched native call (one CKModifyRecordsOperation).
    final dirty = await db.getDirtyEntries();
    if (dirty.isNotEmpty) {
      await _kChannel.invokeMethod<void>(
          'saveEntries', dirty.map((e) => e.toJsonMap()).toList());
      await db.markEntriesPushed([
        for (final e in dirty) (uuid: e.uuid, lastModified: e.lastModified),
      ]);
    }

    // Plans and their Done / Skip days. One record per plan, and one per
    // plan and day, so two phones marking the same day meet in one record.
    final plans = await db.getDirtyPlans();
    final logs = await db.getDirtyPlanLogs();
    if (plans.isEmpty && logs.isEmpty) return;
    await _kChannel.invokeMethod<void>('saveRecords', [
      for (final p in plans)
        {'type': 'PlaygroundPlan', 'name': 'plan_${p['id']}', 'fields': p},
      for (final l in logs)
        {
          'type': 'PlaygroundPlanLog',
          'name': 'planlog_${l['activity_id']}_${l['date']}',
          'fields': l,
        },
    ]);
    await db.markPlansPushed(plans, logs);
  }

  /// A plan changed on the other phone: this phone's own reminder for it
  /// follows the new days, or goes when the plan was paused or deleted.
  Future<void> _refreshPlanReminders(List plans) async {
    for (final p in plans) {
      final id = (p as Map)['id'] as String? ?? '';
      if (id.isEmpty) continue;
      try {
        final plan = await DatabaseHelper.instance.getRecurringActivity(id);
        if (plan != null && plan.isActive && plan.notifyEnabled) {
          await NotificationService.instance.scheduleRecurringActivity(plan);
        } else {
          await NotificationService.instance.cancelRecurringActivity(plan ??
              RecurringActivity(
                  id: id, title: '', kidNames: const [], repeatDays: const []));
        }
      } catch (e) {
        debugPrint('[CloudKit] plan reminder refresh error: $e');
      }
    }
  }

  Future<void> _fetchAndMerge() async {
    final jsonStr =
        await _kChannel.invokeMethod<String>('fetchChanges');
    if (jsonStr == null || jsonStr.isEmpty || jsonStr == '{}') return;

    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final db = DatabaseHelper.instance;

    // This device now syncs with a different iCloud zone than before: it
    // joined a family's shared log, or lost access to one and is back on its
    // own. That zone has none of this device's records, so all of them are
    // pushed again.
    if (data['zone_changed'] == true) await db.markAllForPush();
    // Joined a family's log: their names win over the ones typed here.
    if (data['joined'] == true) await db.setMeta('family_updated_at', '0');

    // Only merge if there are actual changes
    final entries = data['entries'] as List?;
    final deleted = data['deleted_uuids'] as List?;
    final plans = data['plans'] as List? ?? [];
    final planLogs = data['plan_logs'] as List? ?? [];
    if ((entries != null && entries.isNotEmpty) ||
        (deleted != null && deleted.isNotEmpty) ||
        plans.isNotEmpty ||
        planLogs.isNotEmpty ||
        data['parents'] != null) {
      final changed = await db.mergeFromJson(data);
      if (plans.isNotEmpty) await _refreshPlanReminders(plans);
      if (changed) dataVersion.value++;
    }
  }

  /// Registers the CKDatabaseSubscription so the other device's changes
  /// arrive as silent pushes. Best-effort; polling remains the fallback.
  void _ensureSubscriptions() {
    _kChannel.invokeMethod<void>('ensureSubscriptions').catchError((e) {
      debugPrint('[CloudKit] ensureSubscriptions error: $e');
    });
  }
}
