import 'package:flutter/material.dart';
import '../models/dashboard_prefs.dart';
import '../theme.dart';

class DashboardCustomiseScreen extends StatefulWidget {
  const DashboardCustomiseScreen({super.key});

  @override
  State<DashboardCustomiseScreen> createState() =>
      _DashboardCustomiseScreenState();
}

class _DashboardCustomiseScreenState
    extends State<DashboardCustomiseScreen> {
  final _prefs = DashboardPrefs.instance;

  @override
  void initState() {
    super.initState();
    _prefs.addListener(_rebuild);
  }

  @override
  void dispose() {
    _prefs.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('Customise Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          TextButton(
            onPressed: () {
              // Reset to defaults
              DashboardPrefs.instance
                ..reorder(0, 0) // no-op to trigger rebuild
                ;
              // Actually reset properly:
              for (final s in DashboardPrefs.instance.sections) {
                if (!s.visible) DashboardPrefs.instance.toggleVisibility(s.id);
              }
              // Restore default order
              final current = DashboardPrefs.instance.sections.map((s) => s.id).toList();
              const defaultOrder = [
                'parent_stats', 'kid_stats', 'time_stats',
                'charts', 'activities', 'missed_reasons', 'log',
              ];
              for (var i = 0; i < defaultOrder.length; i++) {
                final from = current.indexOf(defaultOrder[i]);
                if (from != i && from >= 0) {
                  DashboardPrefs.instance.reorder(from, i);
                  current.removeAt(from);
                  current.insert(i, defaultOrder[i]);
                }
              }
            },
            child: Text('Reset',
                style: TextStyle(color: Colors.white.withAlpha(200))),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hint banner
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: c.card,
            child: Text(
              'Drag ☰ to reorder  ·  toggle to show/hide',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: c.txt2),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _prefs.sections.length,
              onReorder: _prefs.reorder,
              itemBuilder: (_, i) {
                final section = _prefs.sections[i];
                return _SectionTile(
                  key: ValueKey(section.id),
                  section: section,
                  c: c,
                  onToggle: () => _prefs.toggleVisibility(section.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final SectionConfig section;
  final AppColors c;
  final VoidCallback onToggle;

  const _SectionTile({
    super.key,
    required this.section,
    required this.c,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 3,
              offset: const Offset(0, 1))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(section.icon,
            color: section.visible ? c.green : c.txt2, size: 22),
        title: Text(
          section.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: section.visible ? c.txt : c.txt2,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: section.visible,
              onChanged: (_) => onToggle(),
            ),
            const SizedBox(width: 4),
            Icon(Icons.drag_handle_rounded, color: c.txt2, size: 22),
          ],
        ),
      ),
    );
  }
}
