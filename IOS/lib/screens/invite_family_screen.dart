import 'package:flutter/material.dart';
import '../sync/sync_service.dart';
import '../theme.dart';

/// "just now" / "3m ago" / "2h ago" / "5d ago".
String _relTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
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
        title: const Text('Remove access?'),
        content: Text(
            '$name will no longer be able to sync with this journal. '
            'Their existing entries stay on their device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final success = await SyncService.instance
        .revokeParticipant(participant['id'] as String);
    if (success && mounted) {
      _toast('$name removed');
      _load();
    } else if (mounted) {
      _toast('Could not remove — try again');
    }
  }

  String _displayName(Map<String, dynamic> p) {
    final name = p['name'] as String? ?? '';
    final email = p['email'] as String? ?? '';
    if (name.isNotEmpty && name != 'Unknown') return name;
    if (email.isNotEmpty) return email;
    return 'Connected user';
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
        title: const Text('Family Sync',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
                label: const Text('Invite someone',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Opens iOS share sheet — send via Messages, WhatsApp, copy link…',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: c.txt2),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Connected people ──────────────────────────
          Text(
            'CONNECTED',
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
                'Last synced ${_relTime(SyncService.instance.lastSyncedAt!)}',
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
          border: Border.all(color: kGreen.withAlpha(80), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Text('👨‍👩‍👧', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share with your family',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: c.txt)),
                const SizedBox(height: 4),
                Text(
                  'Each person uses their own Apple ID — '
                  'no shared accounts needed.',
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              isOwner ? kGreen.withAlpha(30) : const Color(0xFFE3F2FD),
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOwner ? kGreen : const Color(0xFF1565C0)),
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
                    ? 'Owner'
                    : isPending
                        ? 'Invite pending…'
                        : 'Connected',
                style: TextStyle(
                    fontSize: 12,
                    color: isPending ? kAmber : c.txt2),
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('You',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kGreen)),
          ),
        if (onRevoke != null)
          TextButton(
            onPressed: onRevoke,
            style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4)),
            child: const Text('Remove',
                style: TextStyle(fontSize: 13)),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text('No one connected yet',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: c.txt)),
          const SizedBox(height: 6),
          Text(
            'Tap "Invite someone" above to share\nwith your partner or family.',
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
          color: const Color(0xFFF0F4F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How it works',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.txt)),
            const SizedBox(height: 10),
            ...[
              ('1', 'Tap "Invite someone" — iOS share sheet opens'),
              ('2', 'Send the link via Messages, WhatsApp, or copy it'),
              ('3', 'They tap the link → "Accept" → done'),
              ('4', 'Both phones sync automatically every 30 seconds'),
            ].map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                          color: kGreen,
                          borderRadius: BorderRadius.circular(11)),
                      child: Center(
                        child: Text(e.$1,
                            style: const TextStyle(
                                color: Colors.white,
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
