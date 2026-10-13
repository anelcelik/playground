import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/family.dart';
import '../models/recurring_activity.dart';
import '../notifications/notification_service.dart';
import '../settings/app_settings.dart';
import '../sync/sync_service.dart';
import '../theme.dart';
import '../widgets/modernist.dart';
import 'custom_theme_screen.dart';
import 'recurring_activity_form.dart';
import '../l10n/l10n.dart';

/// First launch: welcome, the family's names (nicknames welcome), optional
/// reminders, optional plans, and the look. SetupScreen stays for editing
/// the family later from Settings.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _steps = 6; // welcome, parents, kids, reminders, plans, look

  final _pages = PageController();
  int _step = 0;
  bool _finishing = false;

  final _parents = [TextEditingController(), TextEditingController()];
  final _kids = [TextEditingController(), TextEditingController()];
  NotifPrefs _reminders = const NotifPrefs();
  List<RecurringActivity> _plans = [];

  @override
  void dispose() {
    _pages.dispose();
    for (final c in [..._parents, ..._kids]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _names(List<TextEditingController> fields) =>
      fields.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();

  Family get _family => Family(parents: _names(_parents), kids: _names(_kids));

  bool get _canContinue => switch (_step) {
        1 => _names(_parents).isNotEmpty,
        2 => _names(_kids).isNotEmpty,
        _ => true,
      };

  void _go(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    _pages.animateToPage(step,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final family = _family;
    await DatabaseHelper.instance.saveFamily(family.parents, family.kids);
    await DatabaseHelper.instance.saveNotifPrefs(_reminders);
    if (_reminders.outdoorEnabled) {
      await NotificationService.instance
          .scheduleOutdoor(_reminders.outdoorHour, _reminders.outdoorMinute);
    }
    if (_reminders.logEnabled) {
      await NotificationService.instance
          .scheduleLog(_reminders.logHour, _reminders.logMinute);
    }
    SyncService.instance.sync();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _progress(c),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _welcome(c),
                  _namesPage(
                    c,
                    title: context.l10n.onbParentsTitle,
                    fields: _parents,
                    hints: [context.l10n.parentHint1, context.l10n.parentHint2],
                    note: context.l10n.onbParentsNote,
                  ),
                  _namesPage(
                    c,
                    title: context.l10n.onbKidsTitle,
                    fields: _kids,
                    hints: [context.l10n.onbKidHint1, context.l10n.onbKidHint2],
                    note: context.l10n.onbKidsNote,
                  ),
                  _remindersPage(c),
                  _plansPage(c),
                  _lookPage(c),
                ],
              ),
            ),
            _bottomBar(c),
          ],
        ),
      ),
    );
  }

  // ── Frame ───────────────────────────────────────────────

  Widget _progress(AppColors c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            for (var i = 0; i < _steps; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                    height: 3, color: i <= _step ? c.green : c.hairline),
              ),
            ],
          ],
        ),
      );

  Widget _bottomBar(AppColors c) {
    final last = _step == _steps - 1;
    final optional = _step == 3 || _step == 4;
    final nothingSet = (_step == 3 &&
            !_reminders.outdoorEnabled &&
            !_reminders.logEnabled) ||
        (_step == 4 && _plans.isEmpty);
    final label = switch (_step) {
      0 => context.l10n.getStarted,
      _ when last => context.l10n.startUsingApp,
      _ when optional && nothingSet => context.l10n.skipForNow,
      _ => context.l10n.continueLabel,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border, width: 2)),
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            TextButton(
              onPressed: _finishing ? null : () => _go(_step - 1),
              child: Text(context.l10n.back),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: BlockButton(
              label: label,
              icon: last ? Icons.check : Icons.arrow_forward,
              onTap: !_canContinue || _finishing
                  ? null
                  : last
                      ? _finish
                      : () => _go(_step + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _page(AppColors c, String title, List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        children: [
          Text(title, style: AppType.title.copyWith(color: c.txt)),
          const SizedBox(height: 14),
          ...children,
        ],
      );

  Widget _para(AppColors c, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: AppType.body.copyWith(color: c.txt2, height: 1.5)),
      );

  // ── Steps ───────────────────────────────────────────────

  // The app's name stays English; the language choice comes first so
  // someone who doesn't read English can switch before anything else.
  Widget _welcome(AppColors c) => _page(c, 'Playground Tracker', [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final code in AppSettings.languages)
              SquareChip(
                label: AppSettings.languageNames[code]!,
                small: true,
                selected:
                    AppSettings.instance.locale.languageCode == code,
                onTap: () => AppSettings.instance.setLanguage(code),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _para(c, context.l10n.onbWelcome1),
        _para(c, context.l10n.onbWelcome2),
        Block(
          recessed: true,
          child: Text(
              context.l10n.onbWelcomeNote,
              style: AppType.bodySm.copyWith(color: c.txt)),
        ),
      ]);

  Widget _namesPage(
    AppColors c, {
    required String title,
    required List<TextEditingController> fields,
    required List<String> hints,
    required String note,
  }) =>
      _page(c, title, [
        _para(c, note),
        for (var i = 0; i < fields.length; i++)
          Padding(
            key: ObjectKey(fields[i]),
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fields[i],
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                        hintText: i < hints.length ? hints[i] : context.l10n.name),
                  ),
                ),
                if (fields.length > 1)
                  IconButton(
                    tooltip: context.l10n.remove,
                    icon: Icon(Icons.close, color: c.txt2),
                    onPressed: () {
                      final removed = fields[i];
                      setState(() => fields.removeAt(i));
                      // Its TextField is still mounted until this frame ends.
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => removed.dispose());
                    },
                  ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: SquareChip(
            label: context.l10n.addAnotherChip,
            small: true,
            onTap: () => setState(() => fields.add(TextEditingController())),
          ),
        ),
      ]);

  Widget _remindersPage(AppColors c) => _page(c, context.l10n.remindersSetting, [
        _para(c, context.l10n.onbRemindersIntro),
        _reminderRow(
          c,
          title: context.l10n.onbReminderOutside,
          enabled: _reminders.outdoorEnabled,
          hour: _reminders.outdoorHour,
          minute: _reminders.outdoorMinute,
          onToggle: (v) =>
              _setReminders(_reminders.copyWith(outdoorEnabled: v), v),
          onTime: (t) => setState(() => _reminders = _reminders.copyWith(
              outdoorHour: t.hour, outdoorMinute: t.minute)),
        ),
        const SizedBox(height: 10),
        _reminderRow(
          c,
          title: context.l10n.onbReminderLog,
          enabled: _reminders.logEnabled,
          hour: _reminders.logHour,
          minute: _reminders.logMinute,
          onToggle: (v) => _setReminders(_reminders.copyWith(logEnabled: v), v),
          onTime: (t) => setState(() => _reminders = _reminders.copyWith(
              logHour: t.hour, logMinute: t.minute)),
        ),
        const SizedBox(height: 14),
        _para(c, context.l10n.onbRemindersLater),
      ]);

  void _setReminders(NotifPrefs prefs, bool switchedOn) {
    setState(() => _reminders = prefs);
    if (switchedOn) NotificationService.instance.requestPermission();
  }

  Widget _reminderRow(
    AppColors c, {
    required String title,
    required bool enabled,
    required int hour,
    required int minute,
    required ValueChanged<bool> onToggle,
    required ValueChanged<TimeOfDay> onTime,
  }) =>
      Block(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(),
                      style: AppType.label.copyWith(fontSize: 13, color: c.txt)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: hour, minute: minute),
                        builder: (ctx, child) => MediaQuery(
                          data: MediaQuery.of(ctx).copyWith(
                              alwaysUse24HourFormat:
                                  AppSettings.instance.use24h),
                          child: child!,
                        ),
                      );
                      if (t != null) onTime(t);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                          context.l10n.everyDayAtChange(
                              AppSettings.instance.fmtHM(hour, minute)),
                          style: AppType.bodySm.copyWith(color: c.accentTxt)),
                    ),
                  ),
                ],
              ),
            ),
            SquareSwitch(value: enabled, onChanged: onToggle),
          ],
        ),
      );

  Future<void> _addPlan() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => RecurringActivityForm(family: _family)),
    );
    if (saved != true) return;
    final plans = await DatabaseHelper.instance.getAllRecurringActivities();
    if (mounted) setState(() => _plans = plans);
  }

  Widget _plansPage(AppColors c) => _page(c, context.l10n.plans, [
        _para(c, context.l10n.onbPlansIntro),
        for (final p in _plans)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Block(
              recessed: true,
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: c.accentTxt),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('${p.title} · ${p.repeatDaysLabel}',
                        style: AppType.body.copyWith(color: c.txt)),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        BlockButton(
          label: _plans.isEmpty
              ? context.l10n.addAPlan
              : context.l10n.addAnotherPlan,
          icon: Icons.add,
          outlined: true,
          onTap: _addPlan,
        ),
        const SizedBox(height: 14),
        _para(c, context.l10n.onbPlansLater),
      ]);

  Widget _lookPage(AppColors c) {
    final s = AppSettings.instance;
    return _page(c, context.l10n.onbLookTitle, [
      _para(c, context.l10n.onbLookIntro),
      for (final p in AppPalette.values) ...[
        Block(
          recessed: s.palette == p,
          onTap: () async {
            await s.setPalette(p);
            if (p == AppPalette.custom && mounted) {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CustomThemeScreen()));
            }
            if (mounted) setState(() {});
          },
          child: Row(
            children: [
              for (final sw in swatchesOf(p.fixed ?? s.customColors))
                Container(
                  width: 16,
                  height: 32,
                  decoration: BoxDecoration(
                    color: sw,
                    border: Border.all(color: c.hairline, width: 1),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.label,
                        style: AppType.heading.copyWith(color: c.txt)),
                    const SizedBox(height: 2),
                    Text(p.description,
                        style: AppType.bodySm.copyWith(color: c.txt2)),
                  ],
                ),
              ),
              if (s.palette == p) Icon(Icons.check, color: c.accentTxt),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 10),
      Block(
        child: Row(
          children: [
            Expanded(
              child: Text(context.l10n.hour24Time,
                  style: AppType.body
                      .copyWith(color: c.txt, fontWeight: FontWeight.w700)),
            ),
            SquareSwitch(
              value: s.use24h,
              onChanged: (v) async {
                await s.setUse24h(v);
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
