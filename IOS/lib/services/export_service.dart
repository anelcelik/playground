import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';

/// Settings › Export: every entry as a CSV file, handed to the iPhone's
/// share sheet (Save to Files, Mail, AirDrop). Nothing leaves the phone
/// unless the person picks where it goes.
class ExportService {
  static const _channel = MethodChannel('com.playground.tracker/share');

  /// One row per entry, oldest first. The header and the fixed words are
  /// English whatever the app's language, so the file reads the same
  /// everywhere; names, activities and reasons are as they were typed.
  static String csv(List<Entry> entries) {
    String cell(String? v) {
      final s = v ?? '';
      return s.contains(RegExp('[",\n\r]'))
          ? '"${s.replaceAll('"', '""')}"'
          : s;
    }

    final sorted = [...entries]..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : b.shift.compareTo(a.shift);
      });
    final rows = <List<String?>>[
      [
        'date', 'part of day', 'type', 'who went', 'kids', 'duration',
        'start', 'end', 'activities', 'reason',
      ],
      for (final e in sorted)
        [
          e.date,
          e.vacation || e.noPlayground ? '' : e.shift,
          e.vacation
              ? 'vacation'
              : e.noPlayground
                  ? 'nobody went'
                  : 'visit',
          e.vacation || e.noPlayground ? '' : e.userList.join(' & '),
          e.kidList.join(' & '),
          e.duration,
          e.startTime,
          e.endTime,
          e.activityList.join(' & '),
          e.excuse,
        ],
    ];
    return rows.map((r) => r.map(cell).join(',')).join('\r\n');
  }

  /// Writes the file and opens the share sheet. False when that isn't
  /// possible (not an iPhone, no room for the file).
  static Future<bool> exportLog() async {
    try {
      final entries = await DatabaseHelper.instance.getAllEntries();
      final day = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file =
          File('${Directory.systemTemp.path}/playground-tracker-$day.csv');
      // The byte order mark makes Excel and Numbers read it as UTF-8.
      await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(csv(entries))]);
      await _channel.invokeMethod<void>('shareFile', {'path': file.path});
      return true;
    } catch (e) {
      debugPrint('[export] failed: $e');
      return false;
    }
  }
}
