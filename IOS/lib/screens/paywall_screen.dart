import 'package:flutter/material.dart';

import '../purchase/purchase_service.dart';
import '../theme.dart';

/// Blocks the whole app behind the one-time $0.99 unlock.
///
/// Shown by `_AppRouter` whenever [PurchaseService.isPurchased] is false.
/// Rebuilds automatically once a purchase or restore completes, because
/// [PurchaseService] is a [ChangeNotifier] the router listens to.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final service = PurchaseService.instance;
    final price = service.product?.price ?? '\$0.99';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.park_rounded, size: 72, color: colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Playground Tracker',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track visits, sync with family, and get activity '
                    'reminders — one-time purchase, no subscription, no ads.',
                    style: TextStyle(color: colors.txt2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (service.pendingError != null) ...[
                    Text(
                      service.pendingError!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy || service.product == null
                          ? null
                          : () => _run(service.buy),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Unlock — $price'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _busy ? null : () => _run(service.restore),
                    child: const Text('Restore purchase'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
