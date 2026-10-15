import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/durations.dart';
import '../models/goal.dart';
import '../settings/app_settings.dart';
import '../theme.dart';
import '../widgets/modernist.dart';
import '../l10n/l10n.dart';

/// Settings › Outdoor goal (also a tap on the goal on Today): so many hours
/// a week, month or year. Changes apply as they are tapped.
class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final c = AppColors.of(context);
        final s = AppSettings.instance;
        final goal = s.goal;
        final period = goal?.period ?? GoalPeriod.week;
        final presets = OutdoorGoal.presetHours[period]!;
        final custom =
            goal != null && !presets.any((h) => h * 60 == goal.minutes);

        return Scaffold(
          backgroundColor: c.bg,
          appBar: AppBar(
            title: Text(context.l10n.outdoorGoal,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              SectionLabel(context.l10n.goalPeriod),
              _wrap([
                for (final p in GoalPeriod.values)
                  SquareChip(
                    label: periodLabel(context, p),
                    selected: goal?.period == p,
                    // A new period starts from its own typical amount;
                    // 7 hours a year would make no sense.
                    onTap: () => s.setGoal(OutdoorGoal(
                        p, OutdoorGoal.defaultHours[p]! * 60)),
                  ),
              ]),
              SectionLabel(context.l10n.hoursOutside),
              _wrap([
                for (final h in presets)
                  SquareChip(
                    label: formatMinutes(h * 60),
                    small: true,
                    selected: goal?.minutes == h * 60,
                    onTap: () => s.setGoal(OutdoorGoal(period, h * 60)),
                  ),
                SquareChip(
                  label: custom
                      ? formatMinutes(goal.minutes)
                      : context.l10n.otherAmount,
                  small: true,
                  selected: custom,
                  onTap: () => _askHours(context, period),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Text(context.l10n.goalNote,
                    style: AppType.bodySm.copyWith(color: c.txt2)),
              ),
              if (goal != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: BlockButton(
                    label: context.l10n.turnOffGoal,
                    outlined: true,
                    onTap: () => s.setGoal(null),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _wrap(List<Widget> children) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        child: Wrap(spacing: 8, runSpacing: 8, children: children),
      );

  Future<void> _askHours(BuildContext context, GoalPeriod period) async {
    final ctrl = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.hoursOutside,
            style: AppType.heading.copyWith(color: AppColors.of(ctx).txt)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: ctx.l10n.hoursHint),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.l10n.cancel.toUpperCase())),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(ctx.l10n.save.toUpperCase())),
        ],
      ),
    );
    final hours = int.tryParse(value ?? '');
    if (hours != null && hours > 0 && hours <= 9999) {
      await AppSettings.instance.setGoal(OutdoorGoal(period, hours * 60));
    }
  }
}

/// "Week" / "Month" / "Year".
String periodLabel(BuildContext context, GoalPeriod p) => switch (p) {
      GoalPeriod.week => context.l10n.week,
      GoalPeriod.month => context.l10n.month,
      GoalPeriod.year => context.l10n.year,
    };

/// "7h a week" for Settings, or "Off".
String goalSummary(BuildContext context, OutdoorGoal? g) {
  if (g == null) return context.l10n.goalOff;
  final t = formatMinutes(g.minutes);
  return switch (g.period) {
    GoalPeriod.week => context.l10n.goalAWeek(t),
    GoalPeriod.month => context.l10n.goalAMonth(t),
    GoalPeriod.year => context.l10n.goalAYear(t),
  };
}
