import 'dart:async';

import 'package:flutter/material.dart';

import 'sync_service.dart';

/// Manages the 30-second polling timer and triggers sync on app-foreground.
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
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _doSync());
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
