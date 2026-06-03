import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../notifications/notification_service.dart';

import '../settings/app_settings.dart';
import '../theme.dart';

// Brand accent colours — intentionally fixed in both light and dark mode
const _kGreen   = kGreen;
const _kGreenLt = kGreenLt;
const _kAmber   = kAmber;
const _kBlue    = kBlue;
// _kCard / _kBorder / _kTxt / _kTxt2 / _kBg come from AppColors.of(context) per build()



class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Theme-aware colour getters — readable from any method on this State
  Color get _kCard   => AppColors.of(context).card;
  Color get _kBorder => AppColors.of(context).border;
  Color get _kTxt    => AppColors.of(context).txt;
  Color get _kTxt2   => AppColors.of(context).txt2;
  Color get _kBg     => AppColors.of(context).bg;

  NotifPrefs _prefs = const NotifPrefs();
  bool _loading = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await DatabaseHelper.instance.getNotifPrefs();
    final granted = await NotificationService.instance.requestPermission();
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _permissionGranted = granted;
        _loading = false;
      });
    }
  }

  Future<void> _save(NotifPrefs prefs) async {
    setState(() => _prefs = prefs);
    await DatabaseHelper.instance.saveNotifPrefs(prefs);

    // Apply immediately
    if (prefs.outdoorEnabled) {
      await NotificationService.instance
          .scheduleOutdoor(prefs.outdoorHour, prefs.outdoorMinute);
    } else {
      await NotificationService.instance.cancelOutdoor();
    }
    if (prefs.logEnabled) {
      await NotificationService.instance
          .scheduleLog(prefs.logHour, prefs.logMinute);
    } else {
      await NotificationService.instance.cancelLog();
    }
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) =>
      showTimePicker(
        context: context,
        initialTime: initial,
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

  @override
  Widget build(BuildContext context) {
    final _c2 = AppColors.of(context);
    final _kCard   = _c2.card;
    final _kBorder = _c2.border;
    final _kTxt    = _c2.txt;
    final _kTxt2   = _c2.txt2;
    final _kBg     = _c2.bg;



    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kGreen,
        title: Text(
          '🔔 Notifications',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_permissionGranted)
                    _PermissionBanner(
                      onRetry: () async {
                        final ok = await NotificationService.instance
                            .requestPermission();
                        if (mounted) {
                          setState(() => _permissionGranted = ok);
                        }
                      },
                    ),

                  // ── Outdoor reminder ──────────────────────
                  _NotifCard(
                    icon: '🌳',
                    title: 'Outdoor reminder',
                    description:
                        'Did you take the kids outside today? Fires once a day at the time you choose.',
                    enabled: _prefs.outdoorEnabled,
                    time: TimeOfDay(
                        hour: _prefs.outdoorHour,
                        minute: _prefs.outdoorMinute),
                    onToggle: (v) => _save(_prefs.copyWith(outdoorEnabled: v)),
                    onTimeTap: !_prefs.outdoorEnabled
                        ? null
                        : () async {
                            final t = await _pickTime(TimeOfDay(
                                hour: _prefs.outdoorHour,
                                minute: _prefs.outdoorMinute));
                            if (t != null) {
                              await _save(_prefs.copyWith(
                                  outdoorHour: t.hour,
                                  outdoorMinute: t.minute));
                            }
                          },
                  ),

                  const SizedBox(height: 10),

                  // ── Log reminder ──────────────────────────
                  _NotifCard(
                    icon: '📝',
                    title: 'Log entry reminder',
                    description:
                        "Don't forget to log today's playground visit. Fires once a day at the time you choose.",
                    enabled: _prefs.logEnabled,
                    time: TimeOfDay(
                        hour: _prefs.logHour, minute: _prefs.logMinute),
                    onToggle: (v) => _save(_prefs.copyWith(logEnabled: v)),
                    onTimeTap: !_prefs.logEnabled
                        ? null
                        : () async {
                            final t = await _pickTime(TimeOfDay(
                                hour: _prefs.logHour,
                                minute: _prefs.logMinute));
                            if (t != null) {
                              await _save(_prefs.copyWith(
                                  logHour: t.hour, logMinute: t.minute));
                            }
                          },
                  ),

                  const SizedBox(height: 24),
                  const _InfoNote(),
                ],
              ),
            ),
    );
  }
}

// ── Notification card ─────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTimeTap;

  const _NotifCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeTap,
  });

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final _c2 = AppColors.of(context);
    final _kCard   = _c2.card;
    final _kBorder = _c2.border;
    final _kTxt    = _c2.txt;
    final _kTxt2   = _c2.txt2;
    final _kBg     = _c2.bg;



    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text('$icon ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kTxt),
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeThumbColor: _kGreen,
                activeTrackColor: _kGreenLt.withAlpha(120),
                onChanged: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: _kTxt2, height: 1.5),
          ),
          const SizedBox(height: 14),

          // Time picker row
          GestureDetector(
            onTap: onTimeTap,
            child: AnimatedOpacity(
              opacity: enabled ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFFEDF7ED)
                      : const Color(0xFFF5F5F5),
                  border: Border.all(
                      color: enabled ? _kGreen : _kBorder, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 18, color: enabled ? _kGreen : _kTxt2),
                    const SizedBox(width: 8),
                    Text(
                      'Every day at  ${_fmt(time)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: enabled ? _kGreen : _kTxt2,
                      ),
                    ),
                    if (enabled) ...[
                      const SizedBox(width: 8),
                      Text('— tap to change',
                          style: TextStyle(
                              fontSize: 12,
                              color: _kTxt2,
                              fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permission banner ─────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final _c2 = AppColors.of(context);
    final _kCard   = _c2.card;
    final _kBorder = _c2.border;
    final _kTxt    = _c2.txt;
    final _kTxt2   = _c2.txt2;
    final _kBg     = _c2.bg;



    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFFFCC80), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('⚠️ ', style: TextStyle(fontSize: 20)),
          const Expanded(
            child: Text(
              'Notifications are blocked. Open Settings → Playground Tracker → Allow Notifications.',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B3F00),
                  height: 1.5),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry',
                style: TextStyle(
                    color: _kGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Info note ─────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    final _c2 = AppColors.of(context);
    final _kCard   = _c2.card;
    final _kBorder = _c2.border;
    final _kTxt    = _c2.txt;
    final _kTxt2   = _c2.txt2;
    final _kBg     = _c2.bg;



    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ℹ️  ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              'Notifications are local — no internet needed. '
              'Each person in the family sets their own reminder times on their own device.',
              style: TextStyle(fontSize: 13, color: _kTxt2, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
