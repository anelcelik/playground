import 'dart:math';

import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/calendar_days.dart';
import '../models/durations.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../settings/app_settings.dart';
import '../theme.dart';
import '../widgets/modernist.dart';
import '../widgets/reason_sheet.dart';
import '../l10n/l10n.dart';

/// The second tap. Everything below "who went" is optional and prefilled
/// from the last visit of the same shift, so Save is reachable immediately.
///
/// Returns true if something was written.
Future<bool?> showQuickVisitSheet(
  BuildContext context, {
  required Family family,
  required String date,
  required String shift,
  Entry? existing,
  Entry? prefill,
}) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickVisitSheet(
        family: family,
        date: date,
        shift: shift,
        existing: existing,
        prefill: prefill,
      ),
    );

class _QuickVisitSheet extends StatefulWidget {
  final Family family;
  final String date;
  final String shift;
  final Entry? existing;
  final Entry? prefill;

  const _QuickVisitSheet({
    required this.family,
    required this.date,
    required this.shift,
    this.existing,
    this.prefill,
  });

  @override
  State<_QuickVisitSheet> createState() => _QuickVisitSheetState();
}

class _QuickVisitSheetState extends State<_QuickVisitSheet> {

  late Set<String> _users;
  late Set<String> _kids;
  late Set<String> _activities;
  String? _duration;
  // Advanced: the exact start and end instead of a preset length, in
  // minutes after midnight. The choice is remembered for the next visit.
  late bool _exact;
  int? _start;
  int? _end;
  // Why the parents who are not ticked stayed home. Only kept while
  // someone is unticked; never prefilled from the last visit.
  String? _absentReason;
  List<String> _activityTags = [];
  bool _saving = false;

  Entry? get _source => widget.existing ?? widget.prefill;

  @override
  void initState() {
    super.initState();
    final s = _source;
    // Prefill from the existing entry, else the last visit, else the whole
    // family — a first-time user still lands on a valid, savable state.
    _users = {...?s?.userList};
    if (_users.isEmpty && widget.family.parents.length == 1) {
      _users = {widget.family.parents.first};
    }
    _kids = {...?s?.kidList};
    if (_kids.isEmpty) _kids = {...widget.family.kids};
    _activities = {...?s?.activityList};
    _duration = normalizeDuration(s?.duration);
    final existing = widget.existing;
    // An existing visit opens the way it was logged.
    _exact = existing != null
        ? existing.hasTimes
        : AppSettings.instance.exactTimes;
    if (existing != null && existing.hasTimes) {
      _start = clockMinutes(existing.startTime);
      _end = clockMinutes(existing.endTime);
    }
    if (_exact && (_start == null || _end == null)) _defaultTimes();
    _absentReason = widget.existing?.excuse;
    _loadTags();
  }

  /// Today: ending now, as long as the chosen preset (or an hour). An
  /// earlier day has no "now", so it starts at a typical time instead.
  void _defaultTimes() {
    final length = durationMinutes(_duration) > 0 ? durationMinutes(_duration) : 60;
    final now = DateTime.now();
    if (widget.date == dayKey(now)) {
      _end = (now.hour * 60 + now.minute) ~/ 5 * 5;
      _start = max(0, _end! - length);
    } else {
      _start = widget.shift == 'morning' ? 10 * 60 : 16 * 60;
      _end = min(_start! + length, 23 * 60 + 55);
    }
  }

  /// Length of the advanced log, or null while the end isn't after the start.
  int? get _exactMinutes =>
      _start != null && _end != null && _end! > _start! ? _end! - _start! : null;

  void _setExact(bool v) {
    setState(() {
      _exact = v;
      if (v) {
        if (_start == null || _end == null) _defaultTimes();
      } else if (_exactMinutes != null) {
        _duration = nearestPreset(_exactMinutes!);
      }
    });
    AppSettings.instance.setExactTimes(v);
  }

  Future<void> _pickTime({required bool start}) async {
    final m = (start ? _start : _end) ?? 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx)
            .copyWith(alwaysUse24HourFormat: AppSettings.instance.use24h),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    final v = picked.hour * 60 + picked.minute;
    setState(() {
      if (start) {
        // Moving the start keeps the length, like a calendar event.
        final length = _exactMinutes;
        _start = v;
        if (length != null) _end = min(v + length, 23 * 60 + 59);
      } else {
        _end = v;
      }
    });
  }

  Future<void> _loadTags() async {
    final tags = await DatabaseHelper.instance.getTags('activity');
    if (mounted) setState(() => _activityTags = tags);
  }

  bool get _canSave => _users.isNotEmpty && (!_exact || _exactMinutes != null);

  List<String> get _absent =>
      widget.family.parents.where((p) => !_users.contains(p)).toList();

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = Entry(
      id: widget.existing?.id,
      uuid: widget.existing?.uuid ?? '',
      date: widget.date,
      shift: widget.shift,
      user: _users.join(','),
      vacation: false,
      duration: _exact ? formatMinutes(_exactMinutes!) : _duration,
      kids: _kids.isEmpty ? null : _kids.join(','),
      activities: _activities.isEmpty ? null : _activities.join(','),
      excuse: _absent.isEmpty ? null : _absentReason,
      startTime: _exact ? clockLabel(_start!) : null,
      endTime: _exact ? clockLabel(_end!) : null,
      lastModified: now,
      createdAt: widget.existing?.createdAt,
    );

    if (widget.existing != null) {
      await DatabaseHelper.instance.updateEntry(entry);
    } else {
      await DatabaseHelper.instance.insertEntry(entry);
    }
    // Remember any activity the user typed so it becomes a chip next time.
    for (final a in _activities) {
      await DatabaseHelper.instance.addTag('activity', a);
    }
    if (_absent.isNotEmpty) await rememberReason(_absentReason);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _addActivity() async {
    final ctrl = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.addActivity,
            style: AppType.heading.copyWith(color: AppColors.of(ctx).txt)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: context.l10n.addActivityHint),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel.toUpperCase())),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(context.l10n.add.toUpperCase())),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) {
      setState(() {
        _activities.add(value);
        if (!_activityTags.contains(value)) _activityTags.add(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final title = widget.shift == 'morning'
        ? context.l10n.morningVisit
        : context.l10n.eveningVisit;

    return Container(
      margin: const EdgeInsets.only(top: 52),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(top: BorderSide(color: c.border, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sheet bar — Cancel / title / Save, iOS convention.
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.border, width: 2)),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(context.l10n.cancel,
                        style: AppType.body.copyWith(
                            fontWeight: FontWeight.w600, color: c.txt2)),
                  ),
                ),
                Expanded(
                  child: Text(title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppType.label
                          .copyWith(fontSize: 12, color: c.txt)),
                ),
                InkWell(
                  onTap: _canSave ? _save : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(context.l10n.save,
                        style: AppType.body.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _canSave ? c.accentTxt : c.txt2)),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                SectionLabel(context.l10n.whoWent),
                _wrap([
                  for (final p in widget.family.parents)
                    SquareChip(
                      label: p,
                      selected: _users.contains(p),
                      onTap: () => setState(() => _users.contains(p)
                          ? _users.remove(p)
                          : _users.add(p)),
                    ),
                ]),
                if (_users.isNotEmpty && _absent.isNotEmpty) ...[
                  SectionLabel(context.l10n.whyDidntGo(_absent.join(' & '))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: ReasonChips(
                      selected: _absentReason,
                      onChanged: (r) => setState(() => _absentReason = r),
                    ),
                  ),
                ],
                if (widget.family.kids.isNotEmpty) ...[
                  SectionLabel(context.l10n.kids),
                  _wrap([
                    for (final k in widget.family.kids)
                      SquareChip(
                        label: k,
                        selected: _kids.contains(k),
                        icon: _kids.contains(k) ? Icons.check : null,
                        onTap: () => setState(() =>
                            _kids.contains(k) ? _kids.remove(k) : _kids.add(k)),
                      ),
                  ]),
                ],
                _howLongLabel(c),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _exact ? _timesGrid(c) : _durationGrid(c),
                ),
                SectionLabel(context.l10n.activitiesOptional),
                _wrap([
                  for (final a in {..._activityTags, ..._activities})
                    SquareChip(
                      label: a,
                      small: true,
                      selected: _activities.contains(a),
                      onTap: () => setState(() => _activities.contains(a)
                          ? _activities.remove(a)
                          : _activities.add(a)),
                    ),
                  SquareChip(
                      label: context.l10n.addChip, small: true, onTap: _addActivity),
                ]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                  child: Text(
                      _source == null
                          ? context.l10n.onlyWhoWentRequired
                          : '${widget.shift == 'morning' ? context.l10n.prefilledMorning : context.l10n.prefilledEvening} '
                              '${context.l10n.onlyWhoWentRequired}',
                      style: AppType.bodySm.copyWith(color: c.txt2)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border, width: 2)),
            ),
            child: BlockButton(
              label: widget.existing != null
                  ? context.l10n.updateVisit
                  : context.l10n.saveVisit,
              icon: Icons.check,
              onTap: _canSave ? _save : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrap(List<Widget> children) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        child: Wrap(spacing: 8, runSpacing: 8, children: children),
      );

  /// "How long" with the Advanced toggle on the right, where SectionLabel
  /// would show its trailing value.
  Widget _howLongLabel(AppColors c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 8, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(context.l10n.howLong.toUpperCase(),
                  style: AppType.label.copyWith(color: c.txt2)),
            ),
            Semantics(
              toggled: _exact,
              child: InkWell(
                onTap: () => _setExact(!_exact),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          _exact
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 18,
                          color: _exact ? c.green : c.txt2),
                      const SizedBox(width: 6),
                      Text(context.l10n.advanced.toUpperCase(),
                          style: AppType.label.copyWith(
                              color: _exact ? c.txt : c.txt2,
                              letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  /// Advanced: start and end side by side, the length (or what is wrong)
  /// underneath.
  Widget _timesGrid(AppColors c) {
    final length = _exactMinutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: c.border, width: 2)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: _timeCell(c, context.l10n.startTime, _start,
                        () => _pickTime(start: true))),
                Container(width: 1, color: c.hairline),
                Expanded(
                    child: _timeCell(c, context.l10n.endTime, _end,
                        () => _pickTime(start: false))),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
              length == null
                  ? context.l10n.endAfterStart
                  : context.l10n.timeOutside(formatMinutes(length)),
              style: AppType.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: length == null ? c.accentTxt : c.txt2)),
        ),
      ],
    );
  }

  Widget _timeCell(
          AppColors c, String label, int? minutes, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: AppType.label.copyWith(fontSize: 10, color: c.txt2)),
              const SizedBox(height: 3),
              Text(
                  minutes == null
                      ? '—'
                      : AppSettings.instance.fmtHM(minutes ~/ 60, minutes % 60),
                  style: AppType.body.copyWith(
                      fontSize: 20, fontWeight: FontWeight.w800, color: c.txt)),
            ],
          ),
        ),
      );

  /// 4-column grid of preset durations plus a "—" to clear it. Presets beat
  /// a picker for something logged daily.
  Widget _durationGrid(AppColors c) {
    final cells = [...kDurations, '—'];
    return Container(
      decoration: BoxDecoration(border: Border.all(color: c.border, width: 2)),
      child: Column(
        children: [
          for (var row = 0; row < 2; row++)
            Row(
              children: [
                for (var col = 0; col < 4; col++)
                  Expanded(
                    child: _durationCell(
                      c,
                      cells[row * 4 + col],
                      topBorder: row > 0,
                      rightBorder: col < 3,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _durationCell(AppColors c, String label,
      {required bool topBorder, required bool rightBorder}) {
    final isClear = label == '—';
    final selected = isClear ? _duration == null : _duration == label;
    return InkWell(
      onTap: () => setState(() => _duration = isClear ? null : label),
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected && !isClear ? c.green : Colors.transparent,
          border: Border(
            top: topBorder
                ? BorderSide(color: c.hairline, width: 1)
                : BorderSide.none,
            right: rightBorder
                ? BorderSide(color: c.hairline, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Text(label,
            style: AppType.body.copyWith(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected && !isClear
                    ? c.onAccent
                    : isClear
                        ? c.txt2
                        : c.txt)),
      ),
    );
  }
}
