import 'package:flutter/material.dart';
import '../db/database_helper.dart';

import '../settings/app_settings.dart';
import '../theme.dart';

// Brand accent colours — intentionally fixed in both light and dark mode
const _kGreen   = kGreen;
const _kGreenLt = kGreenLt;
const _kAmber   = kAmber;
const _kBlue    = kBlue;
// _kCard / _kBorder / _kTxt / _kTxt2 / _kBg come from AppColors.of(context) per build()



class SetupScreen extends StatefulWidget {
  final bool isEditing;
  final List<String> initialParents;
  final List<String> initialKids;
  final VoidCallback onComplete;

  const SetupScreen({
    super.key,
    this.isEditing = false,
    this.initialParents = const [],
    this.initialKids = const [],
    required this.onComplete,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Theme-aware colour getters — readable from any method on this State
  Color get _kCard   => AppColors.of(context).card;
  Color get _kBorder => AppColors.of(context).border;
  Color get _kTxt    => AppColors.of(context).txt;
  Color get _kTxt2   => AppColors.of(context).txt2;
  Color get _kBg     => AppColors.of(context).bg;

  final List<TextEditingController> _parents = [];
  final List<TextEditingController> _kids = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      for (final p in widget.initialParents) {
        _parents.add(TextEditingController(text: p));
      }
      for (final k in widget.initialKids) {
        _kids.add(TextEditingController(text: k));
      }
    } else {
      _parents.add(TextEditingController());
      _parents.add(TextEditingController());
      _kids.add(TextEditingController());
      _kids.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in [..._parents, ..._kids]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final parents =
        _parents.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    final kids =
        _kids.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (parents.isEmpty || kids.isEmpty) {
      _toast('Add at least one parent and one kid');
      return;
    }
    await DatabaseHelper.instance.saveFamily(parents, kids);
    widget.onComplete();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
  }

  void _removeCtrl(List<TextEditingController> list, int i) {
    setState(() {
      list[i].dispose();
      list.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _appC2 = AppColors.of(context);
    final _kCard   = _appC2.card;
    final _kBorder = _appC2.border;
    final _kTxt    = _appC2.txt;
    final _kTxt2   = _appC2.txt2;
    final _kBg     = _appC2.bg;


    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kGreen,
        title: Text(
          '🌳 Playground Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing ? 'Family Settings' : 'Welcome! 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _kGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isEditing
                      ? 'Update your family members. Existing entries are not affected.'
                      : "Let's set up your family. You can always add more people later.",
                  style: TextStyle(fontSize: 14, color: _kTxt2, height: 1.5),
                ),
                const SizedBox(height: 18),
                const _SectionLabel('Parents / Grandparents'),
                const SizedBox(height: 8),
                ..._parents.asMap().entries.map(
                  (e) => _PersonRow(
                    key: ValueKey('p${e.key}'),
                    controller: e.value,
                    placeholder: e.key == 0 ? 'e.g. Mum' : e.key == 1 ? 'e.g. Dad' : 'Parent / grandparent name',
                    onRemove: () => _removeCtrl(_parents, e.key),
                  ),
                ),
                _AddButton(
                  label: '+ Add parent',
                  onTap: () => setState(
                      () => _parents.add(TextEditingController())),
                ),
                const SizedBox(height: 16),
                const _SectionLabel('Kids'),
                const SizedBox(height: 8),
                ..._kids.asMap().entries.map(
                  (e) => _PersonRow(
                    key: ValueKey('k${e.key}'),
                    controller: e.value,
                    placeholder: e.key == 0 ? 'e.g. Emma' : e.key == 1 ? 'e.g. Tom' : 'Kid name',
                    onRemove: () => _removeCtrl(_kids, e.key),
                  ),
                ),
                _AddButton(
                  label: '+ Add kid',
                  onTap: () =>
                      setState(() => _kids.add(TextEditingController())),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      widget.isEditing ? 'Save Changes' : 'Save & Start 🌳',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final _appC2 = AppColors.of(context);
    final _kCard   = _appC2.card;
    final _kBorder = _appC2.border;
    final _kTxt    = _appC2.txt;
    final _kTxt2   = _appC2.txt2;
    final _kBg     = _appC2.bg;


    return Text(
      text.toUpperCase(),
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _kTxt2,
          letterSpacing: 0.7),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onRemove;

  const _PersonRow({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final _appC2 = AppColors.of(context);
    final _kCard   = _appC2.card;
    final _kBorder = _appC2.border;
    final _kTxt    = _appC2.txt;
    final _kTxt2   = _appC2.txt2;
    final _kBg     = _appC2.bg;


    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: placeholder,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
          ),
          const SizedBox(width: 7),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: _kBorder, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Center(
                child: Text('×',
                    style: TextStyle(fontSize: 20, color: _kTxt2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final _appC2 = AppColors.of(context);
    final _kCard   = _appC2.card;
    final _kBorder = _appC2.border;
    final _kTxt    = _appC2.txt;
    final _kTxt2   = _appC2.txt2;
    final _kBg     = _appC2.bg;


    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: _kBorder, width: 2),
          borderRadius: BorderRadius.circular(9),
          color: Colors.white,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _kTxt2, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
