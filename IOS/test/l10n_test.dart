import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playground_tracker/l10n/l10n.dart';

void main() {
  test('plural forms follow each language', () {
    final cs = lookupAppLocalizations(const Locale('cs'));
    expect(cs.daysCount(1), '1 den');
    expect(cs.daysCount(3), '3 dny');
    expect(cs.daysCount(5), '5 dní');
    final bs = lookupAppLocalizations(const Locale('bs'));
    expect(bs.daysCount(21), '21 dan');
    expect(bs.daysCount(22), '22 dana');
    final de = lookupAppLocalizations(const Locale('de'));
    expect(de.playgroundVisits(1), 'Spielplatzbesuch');
    expect(de.playgroundVisits(2), 'Spielplatzbesuche');
  });

  test('built-in reasons stay English when stored, show translated', () {
    final de = lookupAppLocalizations(const Locale('de'));
    expect(reasonLabel(de, 'Rain'), 'Regen');
    expect(reasonLabel(de, 'too late'), 'Zu spät');
    // Typed reasons show as typed; several are listed one by one.
    expect(reasonsLabel(de, 'Rain,Grandma visiting'), 'Regen, Grandma visiting');
  });
}
