import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../theme.dart';
import '../widgets/modernist.dart';
import '../l10n/l10n.dart';

/// Display settings › My colors: pick background, text and accent; every
/// other colour is derived (AppColors.custom). Changes apply at once, so the
/// whole app is the preview; the block at the top shows the main pieces.
class CustomThemeScreen extends StatefulWidget {
  const CustomThemeScreen({super.key});

  @override
  State<CustomThemeScreen> createState() => _CustomThemeScreenState();
}

/// Light grounds, dark grounds, deep inks, then bright accents.
const _swatches = <Color>[
  Color(0xFFFFFFFF), Color(0xFFF3F2F2), Color(0xFFFFF4D6), Color(0xFFF4EFE6),
  Color(0xFFE8F1EC), Color(0xFFE3ECF7), Color(0xFF000000), Color(0xFF191817),
  Color(0xFF0E2B24), Color(0xFF1B2333), Color(0xFF2B2B2B), Color(0xFF4A4A4A),
  Color(0xFF12443A), Color(0xFF203A63), Color(0xFF6A1B9A), Color(0xFF8E2C48),
  Color(0xFFEC3013), Color(0xFFF0512E), Color(0xFFFFB31F), Color(0xFF2E7D32),
  Color(0xFF1565C0), Color(0xFF00897B), Color(0xFFD81B60), Color(0xFF7B61FF),
];

enum _Role { background, text, accent }

class _CustomThemeScreenState extends State<CustomThemeScreen> {
  final _hex = {for (final r in _Role.values) r: TextEditingController()};

  AppSettings get _s => AppSettings.instance;

  Color _colorOf(_Role r) => switch (r) {
        _Role.background => _s.customBg,
        _Role.text => _s.customTxt,
        _Role.accent => _s.customAccent,
      };

  static String _hexOf(Color c) =>
      (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  @override
  void initState() {
    super.initState();
    for (final r in _Role.values) {
      _hex[r]!.text = _hexOf(_colorOf(r));
    }
  }

  @override
  void dispose() {
    for (final c in _hex.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _set(_Role r, Color c) async {
    _hex[r]!.text = _hexOf(c);
    await switch (r) {
      _Role.background => _s.setCustomColors(bg: c),
      _Role.text => _s.setCustomColors(txt: c),
      _Role.accent => _s.setCustomColors(accent: c),
    };
    if (mounted) setState(() {});
  }

  void _fromHex(_Role r, String v) {
    final clean = v.replaceAll('#', '').trim();
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(clean)) return;
    _set(r, Color(0xFF000000 | int.parse(clean, radix: 16)));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final textContrast = contrastRatio(_s.customTxt, _s.customBg);
    final accentContrast = contrastRatio(_s.customAccent, _s.customBg);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(context.l10n.themeMyColors,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _preview(c),
          if (textContrast < 4.5)
            _warning(c,
                context.l10n.contrastTextWarning(textContrast.toStringAsFixed(1))),
          if (accentContrast < 3)
            _warning(c,
                context.l10n.contrastAccentWarning(accentContrast.toStringAsFixed(1))),
          for (final r in _Role.values) _picker(c, r),
        ],
      ),
    );
  }

  Widget _preview(AppColors c) => Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.bg,
          border: Border.all(color: c.border, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.today, style: AppType.title.copyWith(color: c.txt)),
            const SizedBox(height: 12),
            Block(
              recessed: true,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.morning.toUpperCase(),
                            style: AppType.label
                                .copyWith(fontSize: 13, color: c.txt)),
                        const SizedBox(height: 2),
                        Text('${context.l10n.sampleMom} · Mia & Leo · 1h',
                            style: AppType.bodySm.copyWith(color: c.txt2)),
                      ],
                    ),
                  ),
                  Icon(Icons.check, size: 15, color: c.accentTxt),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SquareChip(label: context.l10n.sampleMom, selected: true),
                SquareChip(label: context.l10n.sampleDad),
              ],
            ),
            const SizedBox(height: 12),
            // An action, so it draws enabled like the real one.
            BlockButton(
                label: context.l10n.saveVisit, icon: Icons.check, onTap: () {}),
          ],
        ),
      );

  Widget _warning(AppColors c, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, size: 16, color: c.accentTxt),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: AppType.bodySm.copyWith(color: c.txt))),
          ],
        ),
      );

  Widget _picker(AppColors c, _Role r) {
    final current = _colorOf(r);
    final title = switch (r) {
      _Role.background => context.l10n.colorBackground,
      _Role.text => context.l10n.colorText,
      _Role.accent => context.l10n.colorAccent,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _swatches)
                Semantics(
                  button: true,
                  selected: s.toARGB32() == current.toARGB32(),
                  label: '#${_hexOf(s)}',
                  child: GestureDetector(
                    onTap: () => _set(r, s),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: s,
                        border: Border.all(
                            color: s.toARGB32() == current.toARGB32()
                                ? c.txt
                                : c.hairline,
                            width: s.toARGB32() == current.toARGB32() ? 3 : 1),
                      ),
                      child: s.toARGB32() == current.toARGB32()
                          ? Icon(Icons.check,
                              size: 18,
                              color: contrastRatio(Colors.white, s) >=
                                      contrastRatio(Colors.black, s)
                                  ? Colors.white
                                  : Colors.black)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: current,
                  border: Border.all(color: c.hairline, width: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _hex[r],
                  maxLength: 7,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    prefixText: '#',
                    hintText: 'RRGGBB',
                    counterText: '',
                    isDense: true,
                  ),
                  onChanged: (v) => _fromHex(r, v),
                  onSubmitted: (v) => _fromHex(r, v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
