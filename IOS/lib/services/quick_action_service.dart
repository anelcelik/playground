import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

/// iOS long-press app-icon shortcuts ("Log a Visit" / "View Dashboard") —
/// registered once at startup. HomeScreen listens for [lastAction] and
/// jumps to the matching tab, whether the shortcut launched the app cold
/// or was tapped while it was already running.
///
/// No custom icons are set (the [ShortcutItem.icon] param is omitted) —
/// that would need an icon asset bundled into the iOS project, and a
/// missing one fails silently to a blank glyph rather than an error, so
/// it's not worth the risk for a text-only shortcut list.
class QuickActionService {
  static final QuickActionService instance = QuickActionService._();
  QuickActionService._();

  static const logEntryType = 'log_entry';
  static const dashboardType = 'dashboard';

  final _plugin = const QuickActions();

  /// The most recent shortcut tap's type; null once consumed. HomeScreen
  /// both listens for changes and checks the current value on mount, to
  /// cover a cold launch where the callback fires before anyone's
  /// subscribed yet.
  final ValueNotifier<String?> lastAction = ValueNotifier(null);

  Future<void> init() async {
    _plugin.initialize((type) => lastAction.value = type);
    await _plugin.setShortcutItems(const [
      ShortcutItem(type: logEntryType, localizedTitle: 'Log a Visit'),
      ShortcutItem(type: dashboardType, localizedTitle: 'View Dashboard'),
    ]);
  }
}
