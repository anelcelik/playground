import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../theme.dart';
import '../widgets/modernist.dart';

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
  static const _durations = ['15m', '30m', '45m', '1h', '1.5h', '2h', '2h+'];

  late Set<String> _users;
  late Set<String> _kids;
  late Set<String> _activities;
  String? _duration;
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
    _duration = s?.duration;
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await DatabaseHelper.instance.getTags('activity');
    if (mounted) setState(() => _activityTags = tags);
  }

  bool get _canSave => _users.isNotEmpty;

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
      duration: _duration,
      kids: _kids.isEmpty ? null : _kids.join(','),
      activities: _activities.isEmpty ? null : _activities.join(','),
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
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _addActivity() async {
    final ctrl = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add activity',
            style: AppType.heading.copyWith(color: AppColors.of(ctx).txt)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Sandpit'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('ADD')),
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
    final title = '${widget.shift == 'morning' ? 'Morning' : 'Evening'} visit';

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
                    child: Text('Cancel',
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
                    child: Text('Save',
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
                const SectionLabel('Who went'),
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
                if (widget.family.kids.isNotEmpty) ...[
                  const SectionLabel('Kids'),
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
                const SectionLabel('How long'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _durationGrid(c),
                ),
                const SectionLabel('Activities  ·  optional'),
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
                      label: '+ Add', small: true, onTap: _addActivity),
                ]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                  child: Text(
                      _source == null
                          ? 'Only “who went” is required.'
                          : 'Prefilled from your last ${widget.shift} visit. '
                              'Only “who went” is required.',
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
              label: widget.existing != null ? 'Update visit' : 'Save visit',
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

  /// 4-column grid of preset durations plus a "—" to clear it. Presets beat
  /// a picker for something logged daily.
  Widget _durationGrid(AppColors c) {
    final cells = [..._durations, '—'];
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
                    ? Colors.white
                    : isClear
                        ? c.txt2
                        : c.txt)),
      ),
    );
  }
}
