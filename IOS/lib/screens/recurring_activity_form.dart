import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';
import '../models/recurring_activity.dart';
import '../notifications/notification_service.dart';

import '../settings/app_settings.dart';
import '../theme.dart';

// Brand accent colours — intentionally fixed in both light and dark mode
const _kGreen   = kGreen;
const _kGreenLt = kGreenLt;
const _kAmber   = kAmber;
const _kBlue    = kBlue;
// _kCard / _kBorder / _kTxt / _kTxt2 / _kBg come from AppColors.of(context) per build()



const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class RecurringActivityForm extends StatefulWidget {
  final Family family;
  final RecurringActivity? existing; // null = creating new

  const RecurringActivityForm({
    super.key,
    required this.family,
    this.existing,
  });

  @override
  State<RecurringActivityForm> createState() => _RecurringActivityFormState();
}

class _RecurringActivityFormState extends State<RecurringActivityForm> {
  // Theme-aware colour getters — readable from any method on this State
  Color get _kCard   => AppColors.of(context).card;
  Color get _kBorder => AppColors.of(context).border;
  Color get _kTxt    => AppColors.of(context).txt;
  Color get _kTxt2   => AppColors.of(context).txt2;
  Color get _kBg     => AppColors.of(context).bg;

  final _titleCtrl = TextEditingController();
  late Set<String> _selKids;
  late Set<int> _selDays;
  String? _dateFrom;
  String? _dateTo;
  late String _shift;
  late bool _isActive;
  late bool _notifyEnabled;
  late int _notifyHour;
  late int _notifyMinute;
  late TextEditingController _notifyMsgCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _titleCtrl.text = a?.title ?? '';
    _selKids = Set.from(a?.kidNames ?? []);
    _selDays = Set.from(a?.repeatDays ?? []);
    _dateFrom = a?.dateFrom;
    _dateTo = a?.dateTo;
    _shift = a?.shift ?? 'morning';
    _isActive = a?.isActive ?? true;
    _notifyEnabled = a?.notifyEnabled ?? false;
    _notifyHour = a?.notifyHour ?? 9;
    _notifyMinute = a?.notifyMinute ?? 0;
    _notifyMsgCtrl = TextEditingController(text: a?.notifyMessage ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notifyMsgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) { _toast('Enter a title'); return; }
    if (_selDays.isEmpty) { _toast('Select at least one day'); return; }
    setState(() => _saving = true);

    final activity = RecurringActivity(
      id: widget.existing?.id ?? Entry.generateUuid(),
      title: title,
      kidNames: widget.family.kids.where(_selKids.contains).toList(),
      repeatDays: ([..._selDays]..sort()),
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      shift: _shift,
      isActive: _isActive,
      notifyEnabled: _notifyEnabled,
      notifyHour: _notifyEnabled ? _notifyHour : null,
      notifyMinute: _notifyEnabled ? _notifyMinute : null,
      notifyMessage: _notifyEnabled && _notifyMsgCtrl.text.trim().isNotEmpty
          ? _notifyMsgCtrl.text.trim()
          : null,
    );

    await DatabaseHelper.instance.upsertRecurringActivity(activity);

    // Reschedule notifications
    if (_notifyEnabled) {
      await NotificationService.instance.scheduleRecurringActivity(activity);
    } else {
      await NotificationService.instance.cancelRecurringActivity(activity);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                Theme.of(ctx).colorScheme.copyWith(primary: _kGreen)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      final s = DateFormat('yyyy-MM-dd').format(picked);
      setState(() => isFrom ? _dateFrom = s : _dateTo = s);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _notifyHour, minute: _notifyMinute),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(
            alwaysUse24HourFormat: AppSettings.instance.use24h),
        child: Theme(
          data: Theme.of(ctx).copyWith(
              colorScheme:
                  Theme.of(ctx).colorScheme.copyWith(primary: _kGreen)),
          child: child!,
        ),
      ),
    );
    if (t != null && mounted) {
      setState(() { _notifyHour = t.hour; _notifyMinute = t.minute; });
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ));
  }

  String _fmtDate(String? d) =>
      d == null ? 'Not set' : DateFormat('d MMM yyyy').format(DateTime.parse(d));

  String _fmtTime() {
    final h = _notifyHour % 12 == 0 ? 12 : _notifyHour % 12;
    final m = _notifyMinute.toString().padLeft(2, '0');
    final p = _notifyHour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {


    final isNew = widget.existing == null;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: _kGreen,
        title: Text(isNew ? 'New Recurring Activity' : 'Edit Activity',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Title
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _clabel('Activity Title'),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Recurring activity',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: _kBorder, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: _kGreenLt, width: 2),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
            ),
          ])),

          // Repeat days
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _clabel('Repeat on'),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: List.generate(7, (i) {
                final sel = _selDays.contains(i);
                return GestureDetector(
                  onTap: () => setState(() =>
                      sel ? _selDays.remove(i) : _selDays.add(i)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? _kGreen : Colors.white,
                      border: Border.all(color: sel ? _kGreen : _kBorder, width: 2),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(_dayLabels[i],
                        style: TextStyle(
                            color: sel ? Colors.white : _kTxt,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                );
              }),
            ),
          ])),

          // Shift — morning or evening
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _clabel('When?'),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _shift = 'morning'),
                  child: _shiftChip('☀️  Morning', _shift == 'morning',
                      const Color(0xFFf57f17)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _shift = 'evening'),
                  child: _shiftChip('🌙  Evening', _shift == 'evening',
                      const Color(0xFF1565c0)),
                ),
              ),
            ]),
          ])),

          // Kids
          if (widget.family.kids.isNotEmpty)
            _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _clabel('Which kids?'),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: widget.family.kids.map((k) {
                  final sel = _selKids.contains(k);
                  return GestureDetector(
                    onTap: () => setState(() =>
                        sel ? _selKids.remove(k) : _selKids.add(k)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFEDF7ED) : Colors.white,
                        border: Border.all(color: sel ? _kGreen : _kBorder, width: 2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: sel ? _kGreen : Colors.white,
                            border: Border.all(color: sel ? _kGreen : _kBorder, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: sel
                              ? Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Text('👧 $k',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ])),

          // Date range
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _clabel('Date range (optional)'),
            Row(children: [
              Expanded(child: _dateBtn('From: ${_fmtDate(_dateFrom)}',
                  () => _pickDate(true))),
              const SizedBox(width: 8),
              Expanded(child: _dateBtn('To: ${_fmtDate(_dateTo)}',
                  () => _pickDate(false))),
            ]),
            if (_dateFrom != null || _dateTo != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      setState(() { _dateFrom = null; _dateTo = null; }),
                  child: Text('Clear dates',
                      style: TextStyle(color: _kTxt2, fontSize: 12)),
                ),
              ),
          ])),

          // Notification
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _clabel('Reminder notification'),
                  Text('Send a notification on activity days',
                      style: TextStyle(fontSize: 13, color: _kTxt2)),
                ]),
              ),
              Switch.adaptive(
                value: _notifyEnabled,
                activeThumbColor: _kGreen,
                activeTrackColor: _kGreenLt.withAlpha(120),
                onChanged: (v) => setState(() => _notifyEnabled = v),
              ),
            ]),
            if (_notifyEnabled) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF7ED),
                    border: Border.all(color: _kGreen, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Icon(Icons.access_time_rounded, size: 18, color: _kGreen),
                    const SizedBox(width: 8),
                    Text('Notify at  ${_fmtTime()}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _kGreen)),
                    const SizedBox(width: 8),
                    Text('— tap to change',
                        style: TextStyle(
                            fontSize: 12, color: _kTxt2,
                            fontStyle: FontStyle.italic)),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notifyMsgCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Custom message (optional)\ne.g. Time to head out!',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(color: _kBorder, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(color: _kGreenLt, width: 2),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Leave empty to use the default message.',
                  style: TextStyle(fontSize: 11, color: _kTxt2),
                ),
              ),
            ],
          ])),

          // Active toggle (only on edit)
          if (!isNew)
            _card(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Active',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Inactive activities are hidden from the daily log',
                      style: TextStyle(fontSize: 12, color: _kTxt2)),
                ]),
                Switch.adaptive(
                  value: _isActive,
                  activeThumbColor: _kGreen,
                  activeTrackColor: _kGreenLt.withAlpha(120),
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            )),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: child,
      );

  Widget _clabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Text(t.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kTxt2,
                letterSpacing: 0.7)),
      );

  Widget _shiftChip(String label, bool sel, Color activeColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? activeColor : Colors.white,
          border: Border.all(color: sel ? activeColor : _kBorder, width: 2),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: sel ? Colors.white : _kTxt,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      );

  Widget _dateBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: _kBorder, width: 2),
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
          child: Text(label,
              style: TextStyle(fontSize: 13, color: _kTxt2),
              overflow: TextOverflow.ellipsis),
        ),
      );
}
