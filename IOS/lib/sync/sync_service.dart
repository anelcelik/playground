import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';

// ── Channel ───────────────────────────────────────────────
// Matches the channel name registered in CloudKitPlugin.swift
const _kChannel = MethodChannel('com.playground.tracker/cloudkit');

enum SyncStatus { idle, syncing, synced, error, unavailable }

class SyncService {
  static final SyncService instance = SyncService._();
  SyncService._();

  final ValueNotifier<SyncStatus> status =
      ValueNotifier(SyncStatus.unavailable);

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  bool get _isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  // ── Full sync cycle ───────────────────────────────────

  /// Called every 30 s and on app foreground.
  /// 1. Pushes all local data to CloudKit (idempotent — CloudKit ignores unchanged records).
  /// 2. Fetches delta changes (records modified since last CKServerChangeToken).
  /// 3. Merges into local SQLite using last_modified tie-breaking.
  Future<void> sync() async {
    if (!_isIos) {
      status.value = SyncStatus.unavailable;
      return;
    }
    if (status.value == SyncStatus.syncing) return;
    status.value = SyncStatus.syncing;

    try {
      await _push();
      await _fetchAndMerge();
      _lastSyncedAt = DateTime.now();
      status.value = SyncStatus.synced;
    } catch (e, st) {
      debugPrint('[CloudKit] sync error: $e\n$st');
      status.value = SyncStatus.error;
    }
  }

  /// Push a single entry immediately after save / soft-delete.
  /// Silent — does not change status dot.
  Future<void> pushEntry(Entry entry) async {
    if (!_isIos) return;
    try {
      await _kChannel.invokeMethod<void>('saveEntry', entry.toJsonMap());
    } catch (e) {
      debugPrint('[CloudKit] pushEntry error: $e');
    }
  }

  // ── Share link (owner creates, partner taps) ──────────

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
    final export = await DatabaseHelper.instance.exportToJson();

    // Push family config
    await _kChannel.invokeMethod<void>('saveConfig', {
      'parents': export['parents'],
      'kids': export['kids'],
      'activity_tags': export['activity_tags'],
      'excuse_tags': export['excuse_tags'],
      'family_updated_at': export['family_updated_at'],
    });

    // Push every entry (CloudKit is idempotent; unchanged records cost one read op)
    final entries = (export['entries'] as List).cast<Map<String, dynamic>>();
    for (final e in entries) {
      await _kChannel.invokeMethod<void>('saveEntry', e);
    }
  }

  Future<void> _fetchAndMerge() async {
    final jsonStr =
        await _kChannel.invokeMethod<String>('fetchChanges');
    if (jsonStr == null || jsonStr.isEmpty || jsonStr == '{}') return;

    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Only merge if there are actual changes
    final entries = data['entries'] as List?;
    if (entries != null && entries.isNotEmpty) {
      await DatabaseHelper.instance.mergeFromJson(data);
    } else if (data['parents'] != null) {
      // Config-only change (no entries changed)
      await DatabaseHelper.instance.mergeFromJson(data);
    }
  }
}
