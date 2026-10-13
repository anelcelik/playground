import 'package:flutter/material.dart';
import '../sync/sync_service.dart';
import '../theme.dart';
import '../l10n/l10n.dart';

/// "just now" / "3 min ago" / "2 h ago" / "5 days ago".
String _relTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  final l = currentL10n;
  if (diff.inSeconds < 60) return l.justNow;
  if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
  return l.daysAgo(diff.inDays);
}

class InviteFamilyScreen extends StatefulWidget {
  const InviteFamilyScreen({super.key});

  @override
  State<InviteFamilyScreen> createState() => _InviteFamilyScreenState();
}

class _InviteFamilyScreenState extends State<InviteFamilyScreen> {
  List<Map<String, dynamic>> _participants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await SyncService.instance.getParticipants();
    if (mounted) setState(() { _participants = p; _loading = false; });
  }

  Future<void> _openShareSheet() async {
    await SyncService.instance.openShareSheet();
    // Refresh after closing the share sheet
    await Future.delayed(const Duration(milliseconds: 800));
    _load();
  }

  Future<void> _revoke(Map<String, dynamic> participant) async {
    final name = _displayName(participant);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.removeAccessQuestion),
        content: Text(context.l10n.removeAccessBody(name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.remove,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final success = await SyncService.instance
        .revokeParticipant(participant['id'] as String);
    if (success && mounted) {
      _toast(context.l10n.personRemoved(name));
      _load();
    } else if (mounted) {
      _toast(context.l10n.couldNotRemove);
    }
  }

  String _displayName(Map<String, dynamic> p) {
    final name = p['name'] as String? ?? '';
    final email = p['email'] as String? ?? '';
    if (name.isNotEmpty && name != 'Unknown') return name;
    if (email.isNotEmpty) return email;
    return currentL10n.connectedUser;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isOwner = _participants.isEmpty ||
        _participants.any((p) => p['role'] == 'owner');

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(context.l10n.familySync,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Hero card ──────────────────────────────────
          _HeroCard(c: c),
          const SizedBox(height: 16),

          // ── Invite button ─────────────────────────────
          if (isOwner) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openShareSheet,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(context.l10n.inviteSomeone,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.of(context).green,
                  foregroundColor: AppColors.of(context).onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                context.l10n.inviteSub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: c.txt2),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Connected people ──────────────────────────
          Text(
            context.l10n.connected.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: c.txt2,
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),

          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator()))
          else if (_participants.isEmpty)
            _EmptyParticipants(c: c, onInvite: isOwner ? _openShareSheet : null)
          else
            ..._participants.map((p) => _ParticipantTile(
                  c: c,
                  participant: p,
                  displayName: _displayName(p),
                  onRevoke: p['role'] == 'participant' && isOwner
                      ? () => _revoke(p)
                      : null,
                )),

          if (!_loading && SyncService.instance.lastSyncedAt != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                context.l10n.lastSynced(
                    _relTime(SyncService.instance.lastSyncedAt!)),
                style: TextStyle(fontSize: 12, color: c.txt2),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── How it works ──────────────────────────────
          _HowItWorks(c: c),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final AppColors c;
  const _HeroCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.of(context).greenTint,
          border: Border.all(color: AppColors.of(context).green.withAlpha(80), width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Row(children: [
          Icon(Icons.people_outline, size: 32, color: AppColors.of(context).green),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.shareWithFamily,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: c.txt)),
                const SizedBox(height: 4),
                Text(
                  context.l10n.shareWithFamilySub,
                  style: TextStyle(
                      fontSize: 13, color: c.txt2, height: 1.4),
                ),
              ],
            ),
          ),
        ]),
      );
}

class _ParticipantTile extends StatelessWidget {
  final AppColors c;
  final Map<String, dynamic> participant;
  final String displayName;
  final VoidCallback? onRevoke;

  const _ParticipantTile({
    required this.c,
    required this.participant,
    required this.displayName,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = participant['role'] == 'owner';
    final status = participant['status'] as String? ?? 'accepted';
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isOwner ? AppColors.of(context).green : Colors.transparent,
            border: Border.all(
                color: isOwner ? AppColors.of(context).green : AppColors.of(context).border,
                width: 2),
          ),
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: AppType.heading.copyWith(
                fontSize: 16,
                color: isOwner ? AppColors.of(context).onAccent : AppColors.of(context).txt),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: c.txt)),
              Text(
                isOwner
                    ? context.l10n.owner
                    : isPending
                        ? context.l10n.invitePending
                        : context.l10n.connected,
                style: TextStyle(
                    fontSize: 12,
                    color: isPending ? AppColors.of(context).txt : c.txt2),
              ),
            ],
          ),
        ),
        if (isOwner)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.of(context).greenTint,
              borderRadius: BorderRadius.zero,
            ),
            child: Text(context.l10n.you,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.of(context).green)),
          ),
        if (onRevoke != null)
          TextButton(
            onPressed: onRevoke,
            style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4)),
            child: Text(context.l10n.remove,
                style: const TextStyle(fontSize: 13)),
          ),
      ]),
    );
  }
}

class _EmptyParticipants extends StatelessWidget {
  final AppColors c;
  final VoidCallback? onInvite;
  const _EmptyParticipants({required this.c, this.onInvite});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(children: [
          Text(context.l10n.noOneConnected,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: c.txt)),
          const SizedBox(height: 6),
          Text(
            context.l10n.noOneConnectedHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: c.txt2),
          ),
        ]),
      );
}

class _HowItWorks extends StatelessWidget {
  final AppColors c;
  const _HowItWorks({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.recessed,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.howItWorks,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.txt)),
            const SizedBox(height: 10),
            ...[
              ('1', context.l10n.howStep1),
              ('2', context.l10n.howStep2),
              ('3', context.l10n.howStep3),
              ('4', context.l10n.howStep4),
            ].map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                          color: AppColors.of(context).green,
                          borderRadius: BorderRadius.zero),
                      child: Center(
                        child: Text(e.$1,
                            style: TextStyle(
                                color: AppColors.of(context).onAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(e.$2,
                            style: TextStyle(
                                fontSize: 13, color: c.txt2))),
                  ]),
                )),
          ],
        ),
      );
}
