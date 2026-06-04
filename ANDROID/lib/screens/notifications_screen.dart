import 'dart:io';
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
      await NotificationService.instance.scheduleOutdoor(
          prefs.outdoorHour, prefs.outdoorMinute,
          customMessage: prefs.outdoorMessage);
    } else {
      await NotificationService.instance.cancelOutdoor();
    }
    if (prefs.logEnabled) {
      await NotificationService.instance.scheduleLog(
          prefs.logHour, prefs.logMinute,
          customMessage: prefs.logMessage);
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
                    defaultMessage: 'Did you take the kids outside today?',
                    enabled: _prefs.outdoorEnabled,
                    time: TimeOfDay(
                        hour: _prefs.outdoorHour,
                        minute: _prefs.outdoorMinute),
                    customMessage: _prefs.outdoorMessage,
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
                    onMessageChanged: (msg) =>
                        _save(_prefs.copyWith(outdoorMessage: msg.isEmpty ? null : msg)),
                  ),

                  const SizedBox(height: 10),

                  // ── Log reminder ──────────────────────────
                  _NotifCard(
                    icon: '📝',
                    title: 'Log entry reminder',
                    defaultMessage: "Don't forget to log today's playground visit",
                    enabled: _prefs.logEnabled,
                    time: TimeOfDay(
                        hour: _prefs.logHour, minute: _prefs.logMinute),
                    customMessage: _prefs.logMessage,
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
                    onMessageChanged: (msg) =>
                        _save(_prefs.copyWith(logMessage: msg.isEmpty ? null : msg)),
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

class _NotifCard extends StatefulWidget {
  final String icon;
  final String title;
  final String defaultMessage;
  final bool enabled;
  final TimeOfDay time;
  final String? customMessage;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTimeTap;
  final ValueChanged<String> onMessageChanged;

  const _NotifCard({
    required this.icon,
    required this.title,
    required this.defaultMessage,
    required this.enabled,
    required this.time,
    this.customMessage,
    required this.onToggle,
    required this.onTimeTap,
    required this.onMessageChanged,
  });

  @override
  State<_NotifCard> createState() => _NotifCardState();
}

class _NotifCardState extends State<_NotifCard> {
  late TextEditingController _msgCtrl;

  @override
  void initState() {
    super.initState();
    _msgCtrl = TextEditingController(text: widget.customMessage ?? '');
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  String _fmtTime(TimeOfDay t) =>
      AppSettings.instance.fmtHM(t.hour, t.minute);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4, offset: const Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Text('${widget.icon} ', style: const TextStyle(fontSize: 22)),
            Expanded(
              child: Text(widget.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.txt)),
            ),
            Switch.adaptive(
              value: widget.enabled,
              activeThumbColor: _kGreen,
              activeTrackColor: _kGreenLt.withAlpha(120),
              onChanged: widget.onToggle,
            ),
          ]),
          const SizedBox(height: 14),

          // Time picker
          GestureDetector(
            onTap: widget.onTimeTap,
            child: AnimatedOpacity(
              opacity: widget.enabled ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.enabled ? const Color(0xFFEDF7ED) : const Color(0xFFF5F5F5),
                  border: Border.all(color: widget.enabled ? _kGreen : c.border, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.access_time_rounded,
                      size: 18, color: widget.enabled ? _kGreen : c.txt2),
                  const SizedBox(width: 8),
                  Text('Every day at  ${_fmtTime(widget.time)}',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: widget.enabled ? _kGreen : c.txt2)),
                  if (widget.enabled) ...[
                    const SizedBox(width: 8),
                    Text('— tap to change',
                        style: TextStyle(fontSize: 12, color: c.txt2, fontStyle: FontStyle.italic)),
                  ],
                ]),
              ),
            ),
          ),

          // Custom message (only shown when enabled)
          if (widget.enabled) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Custom message (optional) — default: "${widget.defaultMessage}"',
                hintMaxLines: 2,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: c.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: _kGreenLt, width: 2),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
              ),
              onChanged: widget.onMessageChanged,
            ),
          ],
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
          const Text('⚠️ ', style: TextStyle(fontSize: 20)),
          Expanded(
            child: Text(
              Platform.isAndroid
                  ? 'Notifications are blocked. Tap Retry to allow, or open Settings → Apps → Playground Tracker → Notifications → Allow.'
                  : 'Notifications are blocked. Open Settings → Playground Tracker → Allow Notifications.',
              style: const TextStyle(
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
