import 'dart:convert';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';

// ── Section metadata (label + icon, never persisted) ─────

const kSectionMeta = <String, ({String label, IconData icon})>{
  'parent_stats':    (label: 'Who went',                  icon: Icons.people_outline),
  'kid_stats':       (label: 'Kids outside',              icon: Icons.child_care_rounded),
  'time_stats':      (label: 'Time & missed days',        icon: Icons.timer_outlined),
  'charts':          (label: 'Charts',                    icon: Icons.pie_chart_outline),
  'activities':      (label: 'Top Activities',            icon: Icons.local_activity_outlined),
  'missed_reasons':  (label: 'No Playground Reasons',     icon: Icons.cancel_outlined),
  'log':             (label: 'Log',                       icon: Icons.list_rounded),
};

// Default order (shown when no prefs are saved yet)
const _kDefaultOrder = [
  'parent_stats', 'kid_stats', 'time_stats',
  'charts', 'activities', 'missed_reasons', 'log',
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

  String get label => kSectionMeta[id]?.label ?? id;
  IconData get icon => kSectionMeta[id]?.icon ?? Icons.widgets_outlined;
}

// ── DashboardPrefs singleton ──────────────────────────────

class DashboardPrefs extends ChangeNotifier {
  static final DashboardPrefs instance = DashboardPrefs._();
  DashboardPrefs._();

  List<SectionConfig> _sections = _kDefaultOrder
      .map((id) => SectionConfig(id: id))
      .toList();

  List<SectionConfig> get sections => _sections;

  Future<void> load() async {
    final raw = await DatabaseHelper.instance.getMeta('dashboard_layout');
    if (raw == null || raw.isEmpty) return;

    try {
      final data = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final saved = data.map(SectionConfig.fromMap).toList();

      // Add any new sections not yet in saved list (app updates)
      for (final id in _kDefaultOrder) {
        if (!saved.any((s) => s.id == id)) saved.add(SectionConfig(id: id));
      }
      // Remove obsolete sections
      saved.removeWhere((s) => !kSectionMeta.containsKey(s.id));

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
