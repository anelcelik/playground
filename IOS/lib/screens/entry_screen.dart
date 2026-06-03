import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/family.dart';
import '../models/entry.dart';
import '../models/recurring_activity.dart';
import '../services/recurring_service.dart';
import '../settings/app_settings.dart';
import '../sync/sync_service.dart';
import '../theme.dart';
import '../widgets/recurring_activity_card.dart';
import 'edit_entry_screen.dart';

// Accent colours stay constant — they are intentional brand colours.
const _kGreen   = kGreen;
const _kGreenLt = kGreenLt;
const _kAmber = kAmber;
const _kBlue  = kBlue;

const _durations = [
  '15 min', '30 min', '45 min', '1 hour', '1.5 hours', '2 hours', '2+ hours',
];

class EntryScreen extends StatefulWidget {
  final Family family;
  final VoidCallback? onEntrySaved;

  const EntryScreen({super.key, required this.family, this.onEntrySaved});

  @override
  EntryScreenState createState() => EntryScreenState();
}

class EntryScreenState extends State<EntryScreen> {
  Color get _kCard   => AppColors.of(context).card;
  Color get _kBorder => AppColors.of(context).border;
  Color get _kTxt    => AppColors.of(context).txt;
  Color get _kTxt2   => AppColors.of(context).txt2;
  Color get _kBg     => AppColors.of(context).bg;

  DateTime _date = DateTime.now();
  bool _isVacation = false;
  final Set<String> _selUsers = {};
  final Set<String> _selShifts = {};
  final Map<String, String?> _dur = {'morning': null, 'evening': null};
  final Map<String, Map<String, bool>> _kids = {'morning': {}, 'evening': {}};
  final Map<String, Set<String>> _acts = {'morning': {}, 'evening': {}};
  final Set<String> _excuseSel = {};
  List<String> _actTags = [];
  List<String> _excTags = [];
  List<Entry> _dayEntries = [];
  List<RecurringActivityStatus> _recurringStatuses = [];

  // Theme-aware colours — updated at the start of every build()

  // Persistent controllers — created once, never leaked
  final _morningActCtrl = TextEditingController();
  final _eveningActCtrl = TextEditingController();
  final _excuseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetKids();
    _loadTags();
    _loadEntries();
    AppSettings.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettingsChanged);
    _morningActCtrl.dispose();
    _eveningActCtrl.dispose();
    _excuseCtrl.dispose();
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  void didUpdateWidget(EntryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.family != widget.family) _resetKids();
  }

  void _resetKids() {
    for (final s in ['morning', 'evening']) {
      _kids[s] = {for (final k in widget.family.kids) k: true};
    }
  }

  Future<void> _loadTags() async {
    final a = await DatabaseHelper.instance.getTags('activity');
    final e = await DatabaseHelper.instance.getTags('excuse');
    if (mounted) setState(() { _actTags = a; _excTags = e; });
  }

  Future<void> _loadEntries() async {
    final date = _fmt(_date);
    final entries = await DatabaseHelper.instance.getEntriesForDate(date);
    final recurring = await RecurringService.instance.getStatusForDate(date);
    if (mounted) {
      setState(() {
        _dayEntries = entries;
        _recurringStatuses = recurring;
      });
    }
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool get _isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(_date.year, _date.month, _date.day);
    return sel.isAfter(today);
  }

  bool get _canGoForward {
    final now = DateTime.now();
    return _date.year < now.year ||
        (_date.year == now.year && _date.month < now.month) ||
        (_date.year == now.year && _date.month == now.month && _date.day < now.day);
  }

  bool get _showExcuseCard {
    if (_isVacation) return false;
    final selCount = widget.family.parents.where((p) => _selUsers.contains(p)).length;
    return selCount > 0 && selCount < widget.family.parents.length;
  }

  List<String> get _excuseFor =>
      widget.family.parents.where((p) => !_selUsers.contains(p)).toList();

  void _shiftDate(int dir) {
    setState(() {
      _date = _date.add(Duration(days: dir));
      if (_isFuture) { _isVacation = true; _selShifts.clear(); }
    });
    _loadEntries();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: _kGreen)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
        if (_isFuture) { _isVacation = true; _selShifts.clear(); }
      });
      _loadEntries();
    }
  }

  Future<void> _save() async {
    if (_selUsers.isEmpty) { _toast('Please select who went'); return; }
    if (!_isVacation && _selShifts.isEmpty) {
      _toast('Select morning, evening or both');
      return;
    }
    final dateStr = _fmt(_date);
    final userStr =
        widget.family.parents.where((p) => _selUsers.contains(p)).join(',');
    final excuseStr = _excuseSel.isEmpty ? null : _excuseSel.join(', ');

    if (_isVacation) {
      final saved = await DatabaseHelper.instance.insertEntry(Entry(
        date: dateStr, shift: 'morning', user: userStr,
        vacation: true,
      ));
      SyncService.instance.pushEntry(saved);
    } else {
      for (final s in _selShifts) {
        final kidStr = widget.family.kids
            .where((k) => _kids[s]![k] == true)
            .join(',');
        final actStr = _acts[s]!.isEmpty ? null : _acts[s]!.join(', ');
        final saved = await DatabaseHelper.instance.insertEntry(Entry(
          date: dateStr, shift: s, user: userStr, vacation: false,
          duration: _dur[s],
          kids: kidStr.isEmpty ? null : kidStr,
          activities: actStr,
          excuse: excuseStr,
        ));
        SyncService.instance.pushEntry(saved);
      }
    }
    _toast('Entry saved ✓');
    _resetForm();
    _loadEntries();
    widget.onEntrySaved?.call();
  }

  void _resetForm() {
    setState(() {
      _isVacation = false;
      _selUsers.clear();
      _selShifts.clear();
      _dur['morning'] = null;
      _dur['evening'] = null;
      _acts['morning'] = {};
      _acts['evening'] = {};
      _excuseSel.clear();
      _resetKids();
    });
  }

  Future<void> _deleteEntry(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete entry?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteEntry(id);
      _loadEntries();
      widget.onEntrySaved?.call();
    }
  }

  Future<void> _addTag(
      String type, List<String> list, Set<String> sel, TextEditingController c) async {
    final val = c.text.trim();
    if (val.isEmpty) return;
    c.clear();
    await DatabaseHelper.instance.addTag(type, val);
    if (mounted) setState(() { if (!list.contains(val)) list.add(val); sel.add(val); });
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final _appC2 = AppColors.of(context);
    final _kCard   = _appC2.card;
    final _kBorder = _appC2.border;
    final _kTxt    = _appC2.txt;
    final _kTxt2   = _appC2.txt2;
    final _kBg     = _appC2.bg;
    final s = AppSettings.instance;
    final now = DateTime.now();
    final isToday = _date.year == now.year && _date.month == now.month && _date.day == now.day;
    final dayLabel = isToday ? 'Today' : DateFormat('EEEE').format(_date);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _clabel('Date'),
              Text(dayLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: _kGreen)),
              const SizedBox(height: 7),
              Row(children: [
                _arrowBtn(() => _shiftDate(-1), Icons.chevron_left),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _kCard,
                        border: Border.all(color: _kBorder, width: 2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        AppSettings.instance.fmtDate(_fmt(_date)),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                _arrowBtn(_canGoForward ? () => _shiftDate(1) : null, Icons.chevron_right),
              ]),
            ],
          )),

          if (_isFuture)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                border: Border.all(color: const Color(0xFFFFE082), width: 2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '📅 Future date — only vacation entries can be logged.',
                style: TextStyle(color: Color(0xFF8A6000), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),

          // Who went
          Opacity(
            opacity: _isFuture ? 0.45 : 1.0,
            child: _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _clabel('Who went?'),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: widget.family.parents.map((p) {
                    final sel = _selUsers.contains(p);
                    return GestureDetector(
                      onTap: _isFuture
                          ? null
                          : () => setState(() => sel ? _selUsers.remove(p) : _selUsers.add(p)),
                      child: _togChip(p, sel, _kGreen),
                    );
                  }).toList(),
                ),
              ],
            )),
          ),

          // When
          Opacity(
            opacity: _isFuture ? 0.45 : 1.0,
            child: _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _clabel('When?'),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _isFuture
                          ? null
                          : () => setState(() => _selShifts.contains('morning')
                              ? _selShifts.remove('morning')
                              : _selShifts.add('morning')),
                      child: _togChip('☀️  Morning', _selShifts.contains('morning'), _kAmber),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isFuture
                          ? null
                          : () => setState(() => _selShifts.contains('evening')
                              ? _selShifts.remove('evening')
                              : _selShifts.add('evening')),
                      child: _togChip('🌙  Evening', _selShifts.contains('evening'), _kBlue),
                    ),
                  ),
                ]),
              ],
            )),
          ),

          // Vacation
          _card(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🏖️  Vacation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Switch.adaptive(
                value: _isVacation,
                activeThumbColor: _kAmber,
                activeTrackColor: _kAmber.withAlpha(100),
                onChanged: (v) => setState(() { _isVacation = v; if (v) _selShifts.clear(); }),
              ),
            ],
          )),

          if (_selShifts.contains('morning') && !_isVacation) _buildShiftCard('morning'),
          if (_selShifts.contains('evening') && !_isVacation) _buildShiftCard('evening'),
          if (_showExcuseCard) _buildExcuseCard(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Save Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),

          // ── Recurring activities for this date ──────────
          if (_recurringStatuses.isNotEmpty) ...[
            Text(
              'PLANNED ACTIVITIES',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kTxt2,
                  letterSpacing: 0.6),
            ),
            const SizedBox(height: 6),
            ..._recurringStatuses.map((s) => RecurringActivityCard(
                  status: s,
                  onConfirm: () => _confirmRecurring(s),
                  onSkip: () => _skipRecurring(s),
                  onTapConfirmed: s.isConfirmed && s.entry != null
                      ? () => _editRecurringEntry(s)
                      : null,
                )),
            const SizedBox(height: 8),
          ],

          Text(
            isToday ? "Today's Log" : 'Log — ${AppSettings.instance.fmtDateFull(_fmt(_date))}',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: _kTxt2, letterSpacing: 0.6),
          ),
          const SizedBox(height: 6),

          if (_dayEntries.isEmpty)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text('No entries yet',
                  style: TextStyle(color: _kTxt2, fontSize: 14)),
            )
          else
            ..._dayEntries.map((e) => _EntryCard(
                  entry: e,
                  family: widget.family,
                  onDelete: () => _deleteEntry(e.id!),
                )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Recurring handlers ────────────────────────────────────

  Future<void> _confirmRecurring(RecurringActivityStatus s) async {
    final result = await RecurringService.instance.confirm(
      activity: s.activity,
      date: _fmt(_date),
      family: widget.family,
    );
    if (mounted) {
      setState(() {
        final i = _recurringStatuses
            .indexWhere((r) => r.activity.id == s.activity.id);
        if (i >= 0) _recurringStatuses[i] = result;
      });
    }
    _loadEntries();
    widget.onEntrySaved?.call();
  }

  Future<void> _skipRecurring(RecurringActivityStatus s) async {
    final reason = await showSkipSheet(context);
    if (reason == null || !mounted) return;
    final result = await RecurringService.instance.skip(
      activity: s.activity,
      date: _fmt(_date),
      reason: reason,
    );
    if (mounted) {
      setState(() {
        final i = _recurringStatuses
            .indexWhere((r) => r.activity.id == s.activity.id);
        if (i >= 0) _recurringStatuses[i] = result;
      });
    }
  }

  Future<void> _editRecurringEntry(RecurringActivityStatus s) async {
    if (s.entry == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEntryScreen(
          entry: s.entry!,
          family: widget.family,
          onSaved: () {
            _loadEntries();
            widget.onEntrySaved?.call();
          },
        ),
      ),
    );
  }

  // ── Shift cards ───────────────────────────────────────────

  Widget _buildShiftCard(String shift) {
    final isM = shift == 'morning';
    final actCtrl = isM ? _morningActCtrl : _eveningActCtrl;
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isM ? '☀️  Morning' : '🌙  Evening',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kTxt)),

        _sublabel('How long?'),
        Wrap(
          spacing: 7, runSpacing: 7,
          children: _durations.map((d) {
            final sel = _dur[shift] == d;
            return GestureDetector(
              onTap: () => setState(() => _dur[shift] = sel ? null : d),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? _kGreen : Colors.white,
                  border: Border.all(color: sel ? _kGreen : _kBorder, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(d,
                    style: TextStyle(
                        color: sel ? Colors.white : _kTxt,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
              ),
            );
          }).toList(),
        ),

        _sublabel('Which kids?'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: widget.family.kids.map((k) {
            final on = _kids[shift]![k] ?? true;
            return GestureDetector(
              onTap: () => setState(() => _kids[shift]![k] = !on),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: on ? const Color(0xFFEDF7ED) : Colors.white,
                  border: Border.all(color: on ? _kGreen : _kBorder, width: 2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: on ? _kGreen : Colors.white,
                        border: Border.all(color: on ? _kGreen : _kBorder, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: on ? Icon(Icons.check, size: 12, color: _kCard) : null,
                    ),
                    const SizedBox(width: 6),
                    Text('👧 $k', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        _sublabel('Activities'),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: _actTags.map((tag) {
            final on = _acts[shift]!.contains(tag);
            return GestureDetector(
              onTap: () => setState(() => on ? _acts[shift]!.remove(tag) : _acts[shift]!.add(tag)),
              child: _tagChip(tag, on),
            );
          }).toList(),
        ),
        const SizedBox(height: 7),
        _tagInput('Add activity...', actCtrl, () => _addTag('activity', _actTags, _acts[shift]!, actCtrl)),
      ],
    ));
  }

  Widget _buildExcuseCard() {
    final ctrl = _excuseCtrl;
    final label = "Why didn't ${_excuseFor.join(' & ')} go? (optional)";
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: _kTxt2, letterSpacing: 0.7)),
        const SizedBox(height: 9),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: _excTags.map((tag) {
            final on = _excuseSel.contains(tag);
            return GestureDetector(
              onTap: () => setState(() => on ? _excuseSel.remove(tag) : _excuseSel.add(tag)),
              child: _tagChip(tag, on),
            );
          }).toList(),
        ),
        const SizedBox(height: 7),
        _tagInput('Add reason...', ctrl, () => _addTag('excuse', _excTags, _excuseSel, ctrl)),
      ],
    ));
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _kCard,
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
                fontSize: 11, fontWeight: FontWeight.w700, color: _kTxt2, letterSpacing: 0.7)),
      );

  Widget _sublabel(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 7),
        child: Text(t.toUpperCase(),
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: _kTxt2, letterSpacing: 0.7)),
      );

  Widget _arrowBtn(VoidCallback? onTap, IconData icon) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            border: Border.all(
                color: onTap != null ? _kBorder : const Color(0xFFE0E0E0), width: 2),
            borderRadius: BorderRadius.circular(9),
            color: _kCard,
          ),
          child: Icon(icon, color: onTap != null ? _kGreen : const Color(0xFFCCCCCC)),
        ),
      );

  Widget _togChip(String label, bool sel, Color activeColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? activeColor : Colors.white,
          border: Border.all(color: sel ? activeColor : _kBorder, width: 2),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: sel ? Colors.white : _kTxt,
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
      );

  Widget _tagChip(String tag, bool on) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: on ? _kGreen : Colors.white,
          border: Border.all(color: on ? _kGreen : _kBorder, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(tag,
            style: TextStyle(
                color: on ? Colors.white : _kTxt,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );

  Widget _tagInput(String hint, TextEditingController ctrl, VoidCallback onAdd) =>
      Row(children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: _kBorder, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: _kGreenLt, width: 2),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 6),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(44, 44),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
          child: Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ]);
}

// ── Entry display card ────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final Entry entry;
  final Family family;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.family,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final _appC2 = AppColors.of(context);
    final _kCard   = _appC2.card;
    final _kBorder = _appC2.border;
    final _kTxt    = _appC2.txt;
    final _kTxt2   = _appC2.txt2;
    final _kBg     = _appC2.bg;

    final e = entry;
    final isM = e.shift == 'morning';
    final shiftBg = isM ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD);
    final shiftColor = isM ? const Color(0xFFBF360C) : const Color(0xFF0D47A1);
    final shiftLabel = isM ? '☀️ Morning' : '🌙 Evening';
    final userDisplay = e.userList.isEmpty ? e.user : e.userList.join(' & ');

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 13, 36, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (!e.vacation)
                    _badge(shiftLabel, shiftBg, shiftColor),
                  if (e.vacation)
                    _badge('🏖️ Vacation', const Color(0xFFFCE4EC), const Color(0xFFB71C1C)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(userDisplay,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ]),
                if (!e.vacation) ...[
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: _kTxt2),
                      children: [
                        const TextSpan(text: '⏱ '),
                        TextSpan(
                          text: e.duration ?? 'NA',
                          style: TextStyle(
                            color: e.duration != null ? _kTxt : const Color(0xFF999999),
                            fontWeight: e.duration != null ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                        const TextSpan(text: '   ·   👧 '),
                        TextSpan(
                          text: e.kidList.isEmpty ? 'NA' : e.kidList.join(' & '),
                          style: TextStyle(
                            color: e.kidList.isNotEmpty ? _kTxt : const Color(0xFF999999),
                            fontWeight: e.kidList.isNotEmpty ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (e.activityList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Wrap(
                        spacing: 4, runSpacing: 4,
                        children: e.activityList.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF7ED),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(t,
                              style: TextStyle(
                                  color: _kGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                    ),
                  if (e.excuse != null && e.excuse!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('💬 ${e.excuse}',
                          style: TextStyle(
                              fontSize: 12, color: _kTxt2, fontStyle: FontStyle.italic)),
                    ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Color(0xFFCCCCCC)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
        child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
