import 'dart:convert';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../l10n/l10n.dart';

// ── Section icons (labels come from the translations; never persisted) ──

const kSectionIcons = <String, IconData>{
  'parent_stats':   Icons.people_outline,
  'calendar':       Icons.grid_on_rounded,
  'kid_stats':      Icons.child_care_rounded,
  'time_stats':     Icons.timer_outlined,
  'charts':         Icons.pie_chart_outline,
  'activities':     Icons.local_activity_outlined,
  'missed_reasons': Icons.cancel_outlined,
};

// Default order (shown when no prefs are saved yet)
const _kDefaultOrder = [
  'calendar', 'parent_stats', 'missed_reasons',
  'kid_stats', 'time_stats', 'charts', 'activities',
];

// ── SectionConfig ─────────────────────────────────────────

class SectionConfig {
  final String id;
  final bool visible;

  const SectionConfig({required this.id, this.visible = true});

  SectionConfig copyWith({bool? visible}) =>
      SectionConfig(id: id, visible: visible ?? this.visible);

  Map<String, dynamic> toMap() => {'id': id, 'visible': visible};

  factory SectionConfig.fromMap(Map<String, dynamic> m) =>
      SectionConfig(id: m['id'] as String, visible: m['visible'] as bool? ?? true);

  /// The section's title on History, in the current language.
  String get label {
    final l = currentL10n;
    return switch (id) {
      'parent_stats' => l.whoTookThem,
      'calendar' => l.oneSquarePerDay,
      'kid_stats' => l.kidsOutside,
      'time_stats' => l.timeAndMissedDays,
      'charts' => l.morningEvening,
      'activities' => l.mostPlayed,
      'missed_reasons' => l.whyNobodyWent,
      _ => id,
    };
  }

  IconData get icon => kSectionIcons[id] ?? Icons.widgets_outlined;
}

// ── DashboardPrefs singleton ──────────────────────────────

class DashboardPrefs extends ChangeNotifier {
  static final DashboardPrefs instance = DashboardPrefs._();
  DashboardPrefs._();

  // The calendar, who-took-them and why-nobody-went blocks are what the
  // History design leads with, so they start visible. The remaining
  // breakdowns start hidden rather than competing for attention — nothing is
  // removed, they are one tap away via the tune button.
  static const _kDefaultHidden = {'charts', 'activities'};

  static List<SectionConfig> _defaults() => _kDefaultOrder
      .map((id) => SectionConfig(id: id, visible: !_kDefaultHidden.contains(id)))
      .toList();

  List<SectionConfig> _sections = _defaults();

  List<SectionConfig> get sections => _sections;

  Future<void> load() async {
    final raw = await DatabaseHelper.instance.getMeta('dashboard_layout');
    if (raw == null || raw.isEmpty) {
      // Nothing saved (first run, or after Delete all data): the defaults.
      _sections = _defaults();
      return;
    }

    try {
      final data = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final saved = data.map(SectionConfig.fromMap).toList();

      // Add any new sections not yet in saved list (app updates)
      for (final id in _kDefaultOrder) {
        if (!saved.any((s) => s.id == id)) saved.add(SectionConfig(id: id));
      }
      // Remove obsolete sections
      saved.removeWhere((s) => !kSectionIcons.containsKey(s.id));

      _sections = saved;
    } catch (_) {
      // Malformed prefs — fall back to defaults
    }
  }

  Future<void> _persist() async {
    final json = jsonEncode(_sections.map((s) => s.toMap()).toList());
    await DatabaseHelper.instance.setMeta('dashboard_layout', json);
    notifyListeners();
  }

  /// Called by ReorderableListView's onReorderItem callback,
  /// which already adjusts newIndex for the removed item.
  void reorder(int oldIndex, int newIndex) {
    final item = _sections.removeAt(oldIndex);
    _sections.insert(newIndex, item);
    _persist();
  }

  /// Toggle a section's visibility by id.
  void toggleVisibility(String id) {
    final i = _sections.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _sections[i] = _sections[i].copyWith(visible: !_sections[i].visible);
    _persist();
  }
}
