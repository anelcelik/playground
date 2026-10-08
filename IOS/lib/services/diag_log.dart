import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

/// A small rolling log in the app's Documents folder (diagnostics.log, next
/// to playground.db), pulled over USB to see what happened in a session that
/// came back from the background as a white screen. Records startup steps,
/// lifecycle changes, whether a frame was drawn after each resume, and
/// uncaught errors. Native scene events go to diagnostics-native.log
/// (AppDelegate.swift).
///
/// Never throws and never blocks: every write is chained and best-effort.
class DiagLog with WidgetsBindingObserver {
  static final DiagLog instance = DiagLog._();
  DiagLog._();

  static const _maxBytes = 256 * 1024;

  Future<File?>? _file;
  Future<void> _chain = Future.value();
  bool _attached = false;
  int _resumeSeq = 0;

  void log(String message) {
    debugPrint('[diag] $message');
    final line = '${DateTime.now().toIso8601String()} [$pid] $message\n';
    _chain = _chain.then((_) async {
      try {
        final f = await (_file ??= _open());
        await f?.writeAsString(line, mode: FileMode.append, flush: true);
      } catch (_) {
        // Diagnostics must never take the app down.
      }
    });
  }

  Future<File?> _open() async {
    try {
      final f = File('${await getDatabasesPath()}/diagnostics.log');
      if (await f.exists() && await f.length() > _maxBytes) {
        // Keep the newer half.
        final text = await f.readAsString();
        await f.writeAsString(text.substring(text.length ~/ 2));
      }
      return f;
    } catch (_) {
      return null;
    }
  }

  /// Lifecycle + error hooks. Call once, after WidgetsFlutterBinding exists.
  void attach() {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addObserver(this);

    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      log('FlutterError: ${details.exceptionAsString()}');
      previous?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      log('Uncaught: $error\n$stack');
      return false; // keep the default reporting too
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('lifecycle: ${state.name}');
    if (state != AppLifecycleState.resumed) return;

    // Coming back after hours could leave the screen white with no new frame
    // drawn. Force one, and record whether it actually reached the screen.
    final seq = ++_resumeSeq;
    final started = DateTime.now();
    var drawn = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      drawn = true;
      final ms = DateTime.now().difference(started).inMilliseconds;
      log('frame drawn after resume #$seq (+${ms}ms)');
    });
    SchedulerBinding.instance.scheduleForcedFrame();
    Timer(const Duration(seconds: 3), () {
      if (!drawn) log('NO FRAME 3s after resume #$seq');
    });
  }

  @override
  void didHaveMemoryPressure() => log('memory pressure');
}
