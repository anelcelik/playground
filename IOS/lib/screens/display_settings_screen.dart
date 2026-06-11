import 'package:flutter/material.dart';
import '../settings/app_settings.dart';
import '../theme.dart';

class DisplaySettingsScreen extends StatelessWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder rebuilds this whole screen whenever a toggle is tapped
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final c = AppColors.of(context);
        final s = AppSettings.instance;

        return Scaffold(
          backgroundColor: c.bg,
          appBar: AppBar(
            title: const Text('Display Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [

              // ── Theme ────────────────────────────────────────
              _SectionHeader('Appearance', c),
              _card(c, Column(children: [
                _RadioRow(
                  c: c,
                  title: 'System',
                  subtitle: 'Follow the device light/dark setting',
                  selected: s.themeMode == ThemeMode.system,
                  onTap: () => s.setThemeMode(ThemeMode.system),
                ),
                Divider(height: 1, color: c.border),
                _RadioRow(
                  c: c,
                  title: 'Light',
                  subtitle: 'Always use the light theme',
                  selected: s.themeMode == ThemeMode.light,
                  onTap: () => s.setThemeMode(ThemeMode.light),
                ),
                Divider(height: 1, color: c.border),
                _RadioRow(
                  c: c,
                  title: 'Dark',
                  subtitle: 'Always use the dark theme',
                  selected: s.themeMode == ThemeMode.dark,
                  onTap: () => s.setThemeMode(ThemeMode.dark),
                ),
              ])),

              const SizedBox(height: 16),

              // ── Time ─────────────────────────────────────────
              _SectionHeader('Time format', c),
              _card(c, Column(children: [
                _RadioRow(
                  c: c,
                  title: '12-hour',
                  subtitle: '3:30 PM  ·  8:00 AM',
                  selected: !s.use24h,
                  onTap: () => s.setUse24h(false),
                ),
                Divider(height: 1, color: c.border),
                _RadioRow(
                  c: c,
                  title: '24-hour',
                  subtitle: '15:30  ·  08:00',
                  selected: s.use24h,
                  onTap: () => s.setUse24h(true),
                ),
              ])),

              const SizedBox(height: 16),

              // ── Date ─────────────────────────────────────────
              _SectionHeader('Date format', c),
              _card(c, Column(children: [
                _RadioRow(
                  c: c,
                  title: 'European',
                  subtitle: '3 Jun 2025  ·  Mon, 3 Jun 2025',
                  selected: s.euDate,
                  onTap: () => s.setEuDate(true),
                ),
                Divider(height: 1, color: c.border),
                _RadioRow(
                  c: c,
                  title: 'US',
                  subtitle: 'Jun 3, 2025  ·  Mon, Jun 3, 2025',
                  selected: !s.euDate,
                  onTap: () => s.setEuDate(false),
                ),
              ])),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Changes apply immediately throughout the app.',
                  style: TextStyle(fontSize: 12, color: c.txt2),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _card(AppColors c, Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: child,
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final AppColors c;
  const _SectionHeader(this.text, this.c);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.txt2,
              letterSpacing: 0.8),
        ),
      );
}

class _RadioRow extends StatelessWidget {
  final AppColors c;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.c,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.txt)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: c.txt2)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            selected
                ? Icon(Icons.check_circle_rounded, color: c.green, size: 24)
                : Icon(Icons.circle_outlined, color: c.border, size: 24),
          ]),
        ),
      );
}
