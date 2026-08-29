import '../theme.dart';
import 'package:flutter/material.dart';
import '../models/recurring_activity.dart';

const _kGreen = Color(0xFF2e7d32);

// ── Public card ───────────────────────────────────────────

class RecurringActivityCard extends StatelessWidget {
  final RecurringActivityStatus status;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;
  final VoidCallback? onTapConfirmed; // opens edit screen

  const RecurringActivityCard({
    super.key,
    required this.status,
    required this.onConfirm,
    required this.onSkip,
    this.onTapConfirmed,
  });

  @override
  Widget build(BuildContext context) {

    if (status.isPending) return _PendingCard(status: status, onConfirm: onConfirm, onSkip: onSkip);
    if (status.isConfirmed) return _ConfirmedCard(status: status, onTap: onTapConfirmed);
    if (status.isSkipped) return _SkippedCard(status: status);
    return _MissedCard(status: status);
  }
}

// ── Skip bottom sheet ─────────────────────────────────────

Future<String?> showSkipSheet(BuildContext context) => showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _SkipSheet(),
    );

class _SkipSheet extends StatelessWidget {
  const _SkipSheet();

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppColors.of(context).border,
                  borderRadius: BorderRadius.zero),
            ),
            const Text('Why skipping?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...[
              ('sick', 'Sick'),
              ('cancelled', 'Cancelled'),
              ('other', 'Other'),
            ].map((e) => _SheetOption(value: e.$1, label: e.$2)),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final String value;
  final String label;
  const _SheetOption({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border:
              Border.all(color: AppColors.of(context).border, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ── State cards ───────────────────────────────────────────

class _PendingCard extends StatelessWidget {
  final RecurringActivityStatus status;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;
  const _PendingCard(
      {required this.status, required this.onConfirm, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final appC2 = AppColors.of(context);
    final kTxt2   = appC2.txt2;

    final a = status.activity;
    return _CardShell(
      border: appC2.border,
      background: appC2.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: Icons.repeat_rounded,
            title: a.title,
            badge: 'Planned',
            badgeBg: appC2.bg,
            badgeFg: kTxt2,
          ),
          if (a.kidNames.isNotEmpty)
            _Detail(a.kidNames.join(' & ')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _ActionBtn(
                label: 'Confirm',
                bg: _kGreen,
                fg: Colors.white,
                onTap: onConfirm,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionBtn(
                label: 'Skip',
                bg: appC2.card,
                fg: kTxt2,
                border: appC2.border,
                onTap: onSkip,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ConfirmedCard extends StatelessWidget {
  final RecurringActivityStatus status;
  final VoidCallback? onTap;
  const _ConfirmedCard({required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final a = status.activity;
    final e = status.entry;
    return GestureDetector(
      onTap: onTap,
      child: _CardShell(
        border: const Color(0xFF66BB6A),
        background: c.greenTint,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              icon: Icons.check_rounded,
              title: a.title,
              badge: 'Done',
              badgeBg: const Color(0xFF66BB6A),
              badgeFg: Colors.white,
            ),
            if (e != null) ...[
              if (e.duration != null) _Detail(e.duration!),
              if (e.kidList.isNotEmpty) _Detail(e.kidList.join(' & ')),
            ],
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Tap to edit',
                    style: TextStyle(
                        fontSize: 11,
                        color: c.green,
                        fontStyle: FontStyle.italic)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkippedCard extends StatelessWidget {
  final RecurringActivityStatus status;
  const _SkippedCard({required this.status});

  @override
  Widget build(BuildContext context) {

    final a = status.activity;
    final reason = switch (status.log?.skipReason) {
      'sick' => 'Sick',
      'cancelled' => 'Cancelled',
      _ => 'Other',
    };
    final c = AppColors.of(context);
    return _CardShell(
      border: c.border,
      background: c.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: Icons.skip_next_rounded,
            title: a.title,
            badge: 'Skipped',
            badgeBg: const Color(0xFFBBBBBB),
            badgeFg: Colors.white,
          ),
          _Detail(reason),
        ],
      ),
    );
  }
}

class _MissedCard extends StatelessWidget {
  final RecurringActivityStatus status;
  const _MissedCard({required this.status});

  @override
  Widget build(BuildContext context) {

    return _CardShell(
      border: const Color(0xFFEF9A9A),
      background: AppColors.of(context).redTint,
      child: _Header(
        icon: Icons.priority_high_rounded,
        title: status.activity.title,
        badge: 'Missed',
        badgeBg: const Color(0xFFEF9A9A),
        badgeFg: const Color(0xFFB71C1C),
      ),
    );
  }
}

// ── Shared primitives ─────────────────────────────────────

class _CardShell extends StatelessWidget {
  final Color border;
  final Color background;
  final Widget child;
  const _CardShell(
      {required this.border, required this.background, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: child,
      );
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final Color badgeBg;
  final Color badgeFg;
  const _Header(
      {required this.icon,
      required this.title,
      required this.badge,
      required this.badgeBg,
      required this.badgeFg});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: badgeFg),
          const SizedBox(width: 8),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15))),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: badgeBg, borderRadius: BorderRadius.zero),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeFg)),
          ),
        ],
      );
}

class _Detail extends StatelessWidget {
  final String text;
  const _Detail(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text,
            style: TextStyle(
                fontSize: 13, color: AppColors.of(context).txt2)),
      );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? border;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.bg,
      required this.fg,
      this.border,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            border: border != null ? Border.all(color: border!, width: 2) : null,
            borderRadius: BorderRadius.zero,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      );
}
