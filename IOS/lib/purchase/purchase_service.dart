import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../db/database_helper.dart';

/// One-time, non-consumable unlock — $0.99, no subscription, never expires.
///
/// Must match the Non-Consumable In-App Purchase product ID created in
/// App Store Connect.
const String kUnlockProductId = 'com.playground.tracker.unlock';

/// Gates the app behind a single $0.99 one-time purchase.
///
/// Entitlement is cached locally in `sync_meta` (device-local, never pushed
/// to CloudKit — see [DatabaseHelper.getMeta]/[setMeta]) so the app stays
/// unlocked offline and each family member's own purchase stays their own.
///
/// On non-iOS platforms (Linux dev, etc.) the paywall is bypassed entirely
/// so `flutter run -d linux` keeps working per the README.
class PurchaseService extends ChangeNotifier {
  static final PurchaseService instance = PurchaseService._();
  PurchaseService._();

  static const _metaKey = 'purchase_unlocked';

  // Set inside init(), after the _isIOS check — merely accessing
  // InAppPurchase.instance triggers the platform plugin's registration,
  // which on Android eagerly opens a billing-client connection over a
  // platform channel. Under flutter_test (default platform: Android)
  // nothing answers that channel, so touching this as a field initializer
  // (i.e. on every construction of PurchaseService, iOS or not) crashes
  // widget tests with a PlatformException before init() even runs.
  late final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  // Unlocked by default — flipped to a real (possibly locked) value inside
  // init() only on iOS. Anything that never calls init() (widget tests,
  // which run under flutter_test's simulated non-iOS platform) stays
  // unlocked rather than getting stuck behind a paywall it can't pay for.
  bool _isPurchased = true;
  bool _storeAvailable = false;
  ProductDetails? _product;
  String? _pendingError;

  bool get isPurchased => _isPurchased;
  ProductDetails? get product => _product;
  String? get pendingError => _pendingError;

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> init() async {
    // Non-iOS (Linux dev, etc.): no paywall, no store to talk to.
    if (!_isIOS) {
      _isPurchased = true;
      return;
    }
    _iap = InAppPurchase.instance;

    // Load cached entitlement first so the router can decide instantly,
    // without waiting on a network round-trip.
    _isPurchased = await DatabaseHelper.instance.getMeta(_metaKey) == '1';

    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) => _pendingError = e.toString(),
    );

    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) return;

    final response = await _iap.queryProductDetails({kUnlockProductId});
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
    }

    // Already unlocked locally (non-consumable, never expires) — no need
    // to hit the store again on every launch.
    if (!_isPurchased) {
      unawaited(_iap.restorePurchases());
    }
  }

  Future<void> buy() async {
    final product = _product;
    if (product == null) return;
    _pendingError = null;
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restore() async {
    if (!_storeAvailable) return;
    _pendingError = null;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          _pendingError = purchase.error?.message ?? 'Purchase failed';
          notifyListeners();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == kUnlockProductId) {
            await DatabaseHelper.instance.setMeta(_metaKey, '1');
            _isPurchased = true;
            notifyListeners();
          }
          break;
        case PurchaseStatus.canceled:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
