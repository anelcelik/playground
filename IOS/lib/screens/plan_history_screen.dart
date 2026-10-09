import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/family.dart';
import '../models/recurring_activity.dart';
import '../services/calendar_service.dart';
import '../services/recurring_service.dart';
import '../settings/app_settings.dart';
import '../theme.dart';
import '../widgets/modernist.dart';
import 'recurring_activity_form.dart';

/// One plan: how often it actually happened, every past day with its
/// outcome, and "Add to Calendar". Opened by tapping a plan in Plans.
///
/// Pops with true when the plan was edited, so the list reloads.
class PlanHistoryScreen extends StatefulWidget {
  final RecurringActivity activity;
  final Family family;

  const PlanHistoryScreen(
      {super.key, required this.activity, required this.family});

  @override
  State<PlanHistoryScreen> createState() => _PlanHistoryScreenState();
}

class _PlanHistoryScreenState extends State<PlanHistoryScreen> {
  List<PlanOccurrence> _days = [];
  bool _loading = true;

  RecurringActivity get _a => widget.activity;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs =
        await DatabaseHelper.instance.getRecurringLogsForActivity(_a.id);
    if (!mounted) return;
    setState(() {
      _days = RecurringService.history(_a, logs, DateTime.now());
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecurringActivityForm(family: widget.family, existing: _a),
      ),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _addToCalendar() async {
    final result = await CalendarService.addPlan(_a);
    if (!mounted) return;
    final msg = switch (result) {
      'saved' => 'Added to your calendar',
      'denied' => 'Calendar access is off — allow it in iPhone Settings',
      'none' => 'This plan has no upcoming day to add',
      'unavailable' => 'Calendar is only available on iPhone',
      _ => null, // cancelled
    };
    if (msg == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final done = _days.where((d) => d.status == 'confirmed').length;
    final skipped = _days.where((d) => d.status == 'skipped').length;
    final missed = _days.where((d) => d.status == 'missed').length;
    final when = [
      _a.repeatDaysLabel,
      _a.shift == 'evening' ? 'Evening' : 'Morning',
      if (_a.notifyEnabled && _a.notifyHour != null) _a.notifyTimeLabel,
      if (_a.kidNames.isNotEmpty) _a.kidNames.join(' & '),
    ].join(' · ');

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(_a.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            tooltip: 'Edit plan',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
        ],
      ),
      body: _loading
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Text(when,
                      style: AppType.bodySm.copyWith(color: c.txt2)),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: c.border, width: 2),
                      bottom: BorderSide(color: c.border, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      _figure(c, done, 'Done', c.green),
                      _figure(c, skipped, 'Skipped', c.txt),
                      _figure(c, missed, 'Missed', c.txt2, last: true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: BlockButton(
                    label: 'Add to Calendar',
                    sublabel: 'Opens iPhone Calendar — add invitees there',
                    icon: Icons.event_outlined,
                    onTap: _addToCalendar,
                  ),
                ),
                SectionLabel('History',
                    trailing: _days.isEmpty ? null : '${_days.length} days'),
                if (_days.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text('No days yet — they show up here once the '
                        'plan has started.',
                        style: AppType.bodySm.copyWith(color: c.txt2)),
                  )
                else ...[
                  for (final d in _days) ...[
                    const Hairline(),
                    _row(c, d),
                  ],
                  const Hairline(),
                ],
                const SizedBox(height: 28),
              ],
            ),
    );
  }

  Widget _figure(AppColors c, int n, String label, Color color,
          {bool last = false}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              right: last
                  ? BorderSide.none
                  : BorderSide(color: c.hairline, width: 1),
            ),
          ),
          child: Column(
            children: [
              Text('$n',
                  style: AppType.title.copyWith(fontSize: 26, color: color)),
              const SizedBox(height: 2),
              Text(label.toUpperCase(),
                  style: AppType.label.copyWith(color: c.txt2, fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _row(AppColors c, PlanOccurrence d) {
    final (String status, IconData icon) = switch (d.status) {
      'confirmed' => ('Done', Icons.check),
      'skipped' => (
          d.reason != null && d.reason!.isNotEmpty
              ? 'Skipped · ${d.reason}'
              : 'Skipped',
          Icons.remove
        ),
      'pending' => ('Today · not done yet', Icons.schedule),
      _ => ('Missed', Icons.close),
    };
    final faded = d.status == 'missed' || d.status == 'pending';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
      child: Row(
        children: [
          Icon(icon,
              size: 15, color: d.status == 'confirmed' ? c.green : c.txt2),
          const SizedBox(width: 12),
          Text(AppSettings.instance.fmtDateFull(d.date),
              style: AppType.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: faded ? c.txt2 : c.txt)),
          const SizedBox(width: 12),
          // A typed skip reason can be long; it gives way, the date doesn't.
          Expanded(
            child: Text(status,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.bodySm.copyWith(color: c.txt2)),
          ),
        ],
      ),
    );
  }
}
