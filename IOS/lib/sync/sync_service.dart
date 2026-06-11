import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';

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
    if (status.value == SyncStatus.syncing) return;
    status.value = SyncStatus.syncing;

    try {
      await _fetchAndMerge().timeout(_kCallTimeout);
      await _push().timeout(_kCallTimeout);
      _lastSyncedAt = DateTime.now();
      status.value = SyncStatus.synced;
      _ensureSubscriptions();
    } catch (e, st) {
      debugPrint('[CloudKit] sync error: $e\n$st');
      status.value = SyncStatus.error;
    }
  }

  /// Push a single entry immediately after save / soft-delete.
  /// Silent — does not change the status dot. On failure the entry keeps its
  /// needs_push flag and is retried on the next sync cycle.
  Future<void> pushEntry(Entry entry) async {
    if (!_isIos) return;
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

  // ── Family sharing ───────────────────────────────────

  /// Opens the native iOS UICloudSharingController.
  /// Shows current participants, lets owner invite via Messages / WhatsApp /
  /// copy link, and revoke access — all in Apple's own UI.
  Future<void> openShareSheet() async {
    if (!_isIos) return;
    try {
      await _kChannel.invokeMethod<void>('openShareSheet');
    } catch (e) {
      debugPrint('[CloudKit] openShareSheet error: $e');
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
    if (dirty.isEmpty) return;

    await _kChannel.invokeMethod<void>(
        'saveEntries', dirty.map((e) => e.toJsonMap()).toList());
    await db.markEntriesPushed([
      for (final e in dirty) (uuid: e.uuid, lastModified: e.lastModified),
    ]);
  }

  Future<void> _fetchAndMerge() async {
    final jsonStr =
        await _kChannel.invokeMethod<String>('fetchChanges');
    if (jsonStr == null || jsonStr.isEmpty || jsonStr == '{}') return;

    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Only merge if there are actual changes
    final entries = data['entries'] as List?;
    final deleted = data['deleted_uuids'] as List?;
    if ((entries != null && entries.isNotEmpty) ||
        (deleted != null && deleted.isNotEmpty) ||
        data['parents'] != null) {
      await DatabaseHelper.instance.mergeFromJson(data);
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
