import 'dart:async';

import 'package:flutter/material.dart';

import 'sync_service.dart';

/// Triggers sync on app-foreground and keeps a slow polling timer as a
/// fallback. Near-real-time updates come from CloudKit silent pushes
/// (see CloudKitPlugin.ensureSubscription), not from this timer.
class SyncController with WidgetsBindingObserver {
  SyncController._();
  static final SyncController instance = SyncController._();

  Timer? _timer;
  bool _started = false;

  SyncStatus get status => SyncService.instance.status.value;
  ValueNotifier<SyncStatus> get statusNotifier => SyncService.instance.status;
  DateTime? get lastSyncedAt => SyncService.instance.lastSyncedAt;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _doSync();
    _timer = Timer.periodic(const Duration(minutes: 3), (_) => _doSync());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _doSync();
  }

  void _doSync() => SyncService.instance.sync();
}
