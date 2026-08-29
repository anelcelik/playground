import 'package:flutter/material.dart';
import '../theme.dart';

// Modernist primitives. Everything in the app is built from these five
// pieces: a rule, a section label, a bordered block, a block button, and
// a chip. No shadows, no radii, no gradients.

/// 2px full-bleed rule — the main structural device.
class Rule extends StatelessWidget {
  final double thickness;
  const Rule({super.key, this.thickness = 2});

  @override
  Widget build(BuildContext context) => Container(
      height: thickness, width: double.infinity, color: AppColors.of(context).border);
}

/// 1px inset hairline — separates rows inside a block.
class Hairline extends StatelessWidget {
  const Hairline({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, width: double.infinity, color: AppColors.of(context).hairline);
}

/// Uppercase section label, optionally with a value on the right.
class SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  final EdgeInsets padding;
  const SectionLabel(this.text,
      {super.key,
      this.trailing,
      this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 9)});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(text.toUpperCase(),
                style: AppType.label.copyWith(color: c.txt2)),
          ),
          if (trailing != null)
            Text(trailing!.toUpperCase(),
                style: AppType.label
                    .copyWith(color: c.txt2, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

/// The primary call to action — a solid accent block, full width.
class BlockButton extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool outlined;
  const BlockButton({
    super.key,
    required this.label,
    this.sublabel,
    this.icon,
    this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = outlined ? c.txt : Colors.white;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          // 56px min — comfortably over the 44pt iOS hit target.
          constraints: const BoxConstraints(minHeight: 56),
          padding: EdgeInsets.symmetric(
              horizontal: outlined ? 14 : 16, vertical: 15),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : c.green,
            border: outlined ? Border.all(color: c.border, width: 2) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label.toUpperCase(),
                        style: AppType.button.copyWith(color: fg)),
                    if (sublabel != null) ...[
                      const SizedBox(height: 3),
                      Text(sublabel!,
                          style: AppType.bodySm.copyWith(
                              color: outlined
                                  ? c.txt2
                                  : Colors.white.withValues(alpha: 0.85))),
                    ],
                  ],
                ),
              ),
              if (icon != null) Icon(icon, size: 20, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable chip — square, 2px border, fills with accent when selected.
class SquareChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dashed;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool small;
  const SquareChip({
    super.key,
    required this.label,
    this.selected = false,
    this.dashed = false,
    this.icon,
    this.onTap,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = selected ? Colors.white : c.txt;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(horizontal: small ? 11 : 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.green : Colors.transparent,
            border: Border.all(
                color: selected ? c.green : c.hairline, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 7),
              ],
              Text(small ? label.toUpperCase() : label,
                  style: small
                      ? AppType.label.copyWith(
                          color: fg, fontSize: 11, letterSpacing: 0.5)
                      : AppType.body
                          .copyWith(color: fg, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bordered content block — the replacement for the old white cards.
class Block extends StatelessWidget {
  final Widget child;
  final bool recessed;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const Block({
    super.key,
    required this.child,
    this.recessed = false,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(14, 13, 14, 13),
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: recessed ? (c.isDark ? kInkD2 : kPaper2) : Colors.transparent,
        border: Border.all(
            color: recessed ? c.hairline : c.border, width: 2),
      ),
      child: child,
    );
    return onTap == null ? body : InkWell(onTap: onTap, child: body);
  }
}
