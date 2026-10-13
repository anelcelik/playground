import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../settings/app_settings.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's texts in the current language. Widgets reading this rebuild
  /// when the language changes.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The same texts for code without a BuildContext: notifications, labels
/// built on models.
AppLocalizations get currentL10n =>
    lookupAppLocalizations(AppSettings.instance.locale);

/// A stored reason in the current language. The built-in ones are saved in
/// English ("Rain") so History counts them together whatever language each
/// phone uses; typed reasons show as typed.
String reasonLabel(AppLocalizations l, String stored) =>
    switch (stored.trim().toLowerCase()) {
      'rain' => l.reasonRain,
      'sick' => l.reasonSick,
      'too late' => l.reasonTooLate,
      'busy' => l.reasonBusy,
      'cancelled' => l.reasonCancelled,
      'other' => l.reasonOther,
      _ => stored.trim(),
    };

/// Several comma-separated reasons, each in the current language.
String reasonsLabel(AppLocalizations l, String stored) =>
    stored.split(',').where((r) => r.trim().isNotEmpty)
        .map((r) => reasonLabel(l, r)).join(', ');

/// Short weekday name, 0 = Monday ("Mon", "Mo.", "Po").
String weekdayShort(int day) => toBeginningOfSentenceCase(
    DateFormat('E').format(DateTime(2024, 1, 1 + day)));
