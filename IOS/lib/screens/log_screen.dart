import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../settings/app_settings.dart';
import '../sync/sync_service.dart';
import '../theme.dart';
import '../widgets/entry_row.dart';
import '../widgets/modernist.dart';

/// Settings › Log: every visit, vacation and nobody-went day, newest first,
/// grouped by day. Tap one to edit or delete it. (Moved here from the Today
/// and History tabs, which keep their summaries.)
class LogScreen extends StatefulWidget {
  final Family family;

  const LogScreen({super.key, required this.family});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  /// Day headers (String) and entries (Entry), in display order.
  List<Object> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await DatabaseHelper.instance.getAllEntries();
    final items = <Object>[];
    String? day;
    for (final e in entries) {
      if (e.date != day) {
        day = e.date;
        items.add(day);
      }
      items.add(e);
    }
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _changed() {
    _load();
    SyncService.instance.sync();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('Log',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: _loading
          ? const SizedBox.shrink()
          : _items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                      'Nothing logged yet. Visits you log on Today show up '
                      'here, newest first.',
                      style: AppType.body.copyWith(color: c.txt2)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    if (item is String) {
                      return SectionLabel(
                          AppSettings.instance.fmtDateFull(item));
                    }
                    return Column(
                      children: [
                        const Hairline(),
                        EntryRow(
                          entry: item as Entry,
                          family: widget.family,
                          onChanged: _changed,
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
