import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';
import '../models/family.dart';

import '../settings/app_settings.dart';
import '../theme.dart';

// Brand accent colours — intentionally fixed in both light and dark mode
const _kGreen   = kGreen;
const _kGreenLt = kGreenLt;
const _kAmber   = kAmber;
const _kBlue    = kBlue;
// _kCard / _kBorder / _kTxt / _kTxt2 / _kBg come from AppColors.of(context) per build()



const _durations = [
  '15 min', '30 min', '45 min', '1 hour', '1.5 hours', '2 hours', '2+ hours',
];

class EditEntryScreen extends StatefulWidget {
  final Entry entry;
  final Family family;
  final VoidCallback? onSaved;

  const EditEntryScreen({
    super.key,
    required this.entry,
    required this.family,
    this.onSaved,
  });

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  // Theme-aware colour getters — readable from any method on this State
  Color get _kCard   => AppColors.of(context).card;
  Color get _kBorder => AppColors.of(context).border;
  Color get _kTxt    => AppColors.of(context).txt;
  Color get _kTxt2   => AppColors.of(context).txt2;
  Color get _kBg     => AppColors.of(context).bg;

  late Set<String> _selUsers;
  late String _shift;
  late String? _duration;
  late Map<String, bool> _kids;
  late Set<String> _acts;
  List<String> _actTags = [];
  final _actCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _selUsers = e.userList.toSet();
    _shift = e.shift;
    _duration = e.duration;
    _kids = {
      for (final k in widget.family.kids)
        k: e.kidList.contains(k),
    };
    _acts = e.activityList.toSet();
    DatabaseHelper.instance.getTags('activity').then((tags) {
      if (mounted) {
        setState(() {
          _actTags = tags;
          // make sure existing activities are in the list
          for (final a in _acts) {
            if (!_actTags.contains(a)) _actTags.insert(0, a);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _actCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selUsers.isEmpty) {
      _toast('Select who went');
      return;
    }
    setState(() => _saving = true);
    final userStr = widget.family.parents
        .where((p) => _selUsers.contains(p))
        .join(',');
    final kidStr =
        widget.family.kids.where((k) => _kids[k] == true).join(',');
    final actStr = _acts.isEmpty ? null : _acts.join(', ');

    final updated = Entry(
      id: widget.entry.id,
      uuid: widget.entry.uuid,
      date: widget.entry.date,
      shift: _shift,
      user: userStr,
      vacation: false,
      duration: _duration,
      kids: kidStr.isEmpty ? null : kidStr,
      activities: actStr,
      excuse: widget.entry.excuse,
      lastModified: DateTime.now().millisecondsSinceEpoch,
      createdAt: widget.entry.createdAt,
    );

    await DatabaseHelper.instance.updateEntry(updated);
    widget.onSaved?.call();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addTag(String val) async {
    final v = val.trim();
    if (v.isEmpty) return;
    _actCtrl.clear();
    await DatabaseHelper.instance.addTag('activity', v);
    if (mounted) {
      setState(() {
        if (!_actTags.contains(v)) _actTags.add(v);
        _acts.add(v);
      });
    }
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

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: _kGreen,
        title: Text('Edit Entry',
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
                    width: 18,
                    height: 18,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Who went
            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _clabel('Who went?'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.family.parents.map((p) {
                    final sel = _selUsers.contains(p);
                    return GestureDetector(
                      onTap: () => setState(() =>
                          sel ? _selUsers.remove(p) : _selUsers.add(p)),
                      child: _togChip(p, sel, _kGreen),
                    );
                  }).toList(),
                ),
              ],
            )),

            // Shift
            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _clabel('When?'),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _shift = 'morning'),
                      child: _togChip(
                          '☀️  Morning', _shift == 'morning', _kAmber),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _shift = 'evening'),
                      child: _togChip(
                          '🌙  Evening', _shift == 'evening', _kBlue),
                    ),
                  ),
                ]),
              ],
            )),

            // Duration
            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _clabel('How long?'),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: _durations.map((d) {
                    final sel = _duration == d;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _duration = sel ? null : d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? _kGreen : Colors.white,
                          border: Border.all(
                              color: sel ? _kGreen : _kBorder, width: 2),
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
              ],
            )),

            // Kids
            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _clabel('Which kids?'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.family.kids.map((k) {
                    final on = _kids[k] ?? false;
                    return GestureDetector(
                      onTap: () => setState(() => _kids[k] = !on),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: on
                              ? const Color(0xFFEDF7ED)
                              : Colors.white,
                          border: Border.all(
                              color: on ? _kGreen : _kBorder, width: 2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: on ? _kGreen : Colors.white,
                                border: Border.all(
                                    color: on ? _kGreen : _kBorder, width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: on
                                  ? Icon(Icons.check,
                                      size: 12, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text('👧 $k',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            )),

            // Activity tags
            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _clabel('Activities'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _actTags.map((tag) {
                    final on = _acts.contains(tag);
                    return GestureDetector(
                      onTap: () => setState(() =>
                          on ? _acts.remove(tag) : _acts.add(tag)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: on ? _kGreen : Colors.white,
                          border: Border.all(
                              color: on ? _kGreen : _kBorder, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                color: on ? Colors.white : _kTxt,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 7),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _actCtrl,
                      decoration: InputDecoration(
                        hintText: 'Add activity...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide:
                              BorderSide(color: _kBorder, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide:
                              BorderSide(color: _kGreenLt, width: 2),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9)),
                      ),
                      onSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () => _addTag(_actCtrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(44, 44),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                    ),
                    child: Text('+',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ],
            )),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(0, 1))
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

  Widget _togChip(String label, bool sel, Color active) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? active : Colors.white,
          border: Border.all(color: sel ? active : _kBorder, width: 2),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: sel ? Colors.white : _kTxt,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      );
}
