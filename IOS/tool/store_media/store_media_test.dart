// App Store screenshots and website GIFs, rendered from the real app with
// real fonts and sample data (not part of the normal test run).
//
//   flutter test tool/store_media/store_media_test.dart
//
// Screens land in build/store_media/screens/ (1320 x 2868, iPhone 6.9"),
// GIF frames in build/store_media/frames/<name>/; tool/store_media/compose.py
// turns them into the finished files in webpagepreparation/screenshots/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playground_tracker/db/database_helper.dart';
import 'package:playground_tracker/l10n/app_localizations.dart';
import 'package:playground_tracker/main.dart';
import 'package:playground_tracker/models/entry.dart';
import 'package:playground_tracker/models/recurring_activity.dart';
import 'package:playground_tracker/settings/app_settings.dart';
import 'package:playground_tracker/theme.dart';
import 'package:playground_tracker/widgets/modernist.dart';

final _sdk = '${Platform.environment['HOME']}/development/flutter';
const _out = 'build/store_media';

// iPhone 16 / 17 Pro Max: 440 x 956 pt at 3x, safe area 62 pt / 34 pt.
const _logical = Size(440, 956);
const _dpr = 3.0;
const _top = 62.0;
const _bottom = 34.0;

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(File(p).readAsBytes().then((b) => ByteData.view(b.buffer)));
  }
  await loader.load();
}

String _d(int daysAgo) => DateFormat('yyyy-MM-dd')
    .format(DateTime.now().subtract(Duration(days: daysAgo)));

/// Three months of a believable family: mostly one parent, sometimes both,
/// a few rainy or sick days, a week of vacation, and three plans with a
/// history of their own.
Future<void> _seed() async {
  await DatabaseHelper.resetForTests();
  final db = DatabaseHelper.instance;
  await db.saveFamily(['Mom', 'Dad'], ['Mia', 'Leo']);
  var ts = 1000;
  Future<void> visit(int ago, String shift, String who,
      {String kids = 'Mia,Leo',
      String dur = '1h',
      String? acts,
      String? excuse}) async {
    await db.insertEntry(Entry(
        uuid: Entry.generateUuid(),
        date: _d(ago),
        shift: shift,
        user: who,
        vacation: false,
        duration: dur,
        kids: kids,
        activities: acts,
        excuse: excuse,
        lastModified: ts++));
  }

  await visit(0, 'morning', 'Mom', acts: 'Swings,Sandpit');
  for (var ago = 1; ago < 95; ago++) {
    if (ago >= 52 && ago <= 58) {
      await db.insertEntry(Entry(
          uuid: Entry.generateUuid(),
          date: _d(ago),
          shift: 'morning',
          user: 'Mom,Dad',
          vacation: true,
          lastModified: ts++));
      continue;
    }
    if (ago % 11 == 4 || ago % 13 == 6) {
      await db.insertEntry(Entry(
          uuid: Entry.generateUuid(),
          date: _d(ago),
          shift: ago.isEven ? 'morning' : 'evening',
          user: 'Mom,Dad',
          vacation: false,
          noPlayground: true,
          excuse: ['Rain', 'Sick', 'Rain', 'Too late'][ago % 4],
          lastModified: ts++));
      continue;
    }
    final both = ago % 5 == 0 || ago % 7 == 1;
    await visit(ago, ago.isEven ? 'morning' : 'evening',
        both ? 'Mom,Dad' : (ago % 3 == 0 ? 'Dad' : 'Mom'),
        kids: ago % 8 == 3 ? 'Mia' : 'Mia,Leo',
        dur: ['45m', '1h', '1.5h', '30m', '1h', '2h'][ago % 6],
        acts: ['Swings,Slide', 'Sandpit', 'Climbing', 'Scooter', 'Slide']
            [ago % 5],
        excuse: both ? null : (ago % 3 == 0 ? 'Work' : null));
    if (ago % 4 == 2) {
      await visit(ago, ago.isEven ? 'evening' : 'morning', 'Dad',
          kids: 'Leo', dur: '45m', acts: 'Football');
    }
  }

  final since = '${_d(60)} 08:00:00';
  await db.upsertRecurringActivity(RecurringActivity(
      id: 'p1',
      title: 'Football',
      kidNames: const ['Leo'],
      repeatDays: const [0, 2],
      shift: 'evening',
      notifyEnabled: true,
      notifyHour: 17,
      notifyMinute: 30,
      createdAt: since));
  await db.upsertRecurringActivity(RecurringActivity(
      id: 'p2',
      title: 'Swimming',
      kidNames: const ['Mia'],
      repeatDays: const [5],
      notifyEnabled: true,
      notifyHour: 9,
      notifyMinute: 0,
      createdAt: since));
  final party = _d(-4);
  await db.upsertRecurringActivity(RecurringActivity(
      id: 'p3',
      title: 'Birthday party',
      kidNames: const ['Mia', 'Leo'],
      repeatDays: [DateTime.parse(party).weekday - 1],
      dateFrom: party,
      dateTo: party));
  // Football mostly happened: its 3rd day back was skipped (sick) and its
  // 6th missed, whatever weekday the screenshots are made on.
  var football = 0;
  for (var ago = 1; ago <= 60; ago++) {
    final day = DateTime.now().subtract(Duration(days: ago));
    final plan = switch (day.weekday) {
      DateTime.monday || DateTime.wednesday => 'p1',
      DateTime.saturday => 'p2',
      _ => null,
    };
    if (plan == null || (ago >= 52 && ago <= 58)) continue;
    if (plan == 'p1') football++;
    final skipped = plan == 'p1' && football == 3;
    if (plan == 'p1' && football == 6) continue; // missed
    await db.upsertRecurringLog(RecurringLog(
        id: 'log$ago',
        activityId: plan,
        date: _d(ago),
        status: skipped ? 'skipped' : 'confirmed',
        skipReason: skipped ? 'sick' : null));
  }
}

// ── Stage: the app plus an iPhone status bar and a finger ────────────

final _stageKey = GlobalKey();
final _touch = ValueNotifier<(Offset, bool)?>(null); // position, pressed

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        key: _stageKey,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(children: [
            const PlaygroundTrackerApp(),
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _top,
                child: IgnorePointer(
                  child: ListenableBuilder(
                    listenable: AppSettings.instance,
                    builder: (_, __) => _StatusBar(
                        color: AppSettings.instance.colors.isDark
                            ? Colors.white
                            : Colors.black),
                  ),
                )),
            ValueListenableBuilder(
              valueListenable: _touch,
              builder: (_, t, __) {
                if (t == null) return const SizedBox.shrink();
                final size = t.$2 ? 40.0 : 48.0;
                return Positioned(
                  left: t.$1.dx - size / 2,
                  top: t.$1.dy - size / 2,
                  child: IgnorePointer(
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x55000000),
                        border: Border.all(
                            color: const Color(0xCCFFFFFF), width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 8)
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ]),
        ),
      );
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget bar(double h) => Container(
        width: 3.2,
        height: h,
        margin: const EdgeInsets.only(left: 1.6),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(1)));
    return Padding(
      padding: const EdgeInsets.only(top: 21),
      child: Row(children: [
        Expanded(
          child: Center(
            child: Text('9:41',
                style: TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.2)),
          ),
        ),
        const SizedBox(width: 126), // the Dynamic Island
        Expanded(
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [bar(4.5), bar(6.5), bar(9), bar(11.5)]),
              const SizedBox(width: 6),
              Icon(Icons.wifi_rounded, size: 18, color: color),
              const SizedBox(width: 6),
              Container(
                width: 26,
                height: 12.5,
                padding: const EdgeInsets.all(1.6),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: color.withValues(alpha: 0.4), width: 1.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(2))),
              ),
              Container(
                width: 1.6,
                height: 4.5,
                margin: const EdgeInsets.only(left: 1),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(1)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Capture ──────────────────────────────────────────────────────────

Future<void> _png(WidgetTester t, String path, double ratio) async {
  final boundary =
      _stageKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await t.runAsync(() async {
    final img = await boundary.toImage(pixelRatio: ratio);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

/// Lets real async work (the database) finish and animations run out.
Future<void> settle(WidgetTester t, [int rounds = 10]) async {
  for (var i = 0; i < rounds; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 60));
  }
}

/// Settles until [f] shows up: Today loads its day from the database, which
/// answers in real time while the app's clock is simulated.
Future<void> until(WidgetTester t, Finder f, {int max = 80}) =>
    _until(t, f, max: max);

Future<void> _until(WidgetTester t, Finder f, {int max = 80}) async {
  for (var i = 0; i < max && f.evaluate().isEmpty; i++) {
    await settle(t, 1);
  }
  expect(f, findsWidgets);
  await settle(t, 4);
}

Future<void> shot(WidgetTester t, String name) async {
  await settle(t);
  await _png(t, '$_out/screens/$name.png', _dpr);
}

/// GIF recorder: one frame per [dtMs] of app time, with a finger shown for
/// every tap and drag.
class Rec {
  Rec(this.t, this.name, {this.ratio = 1.5, this.dtMs = 40}) {
    final d = Directory('$_out/frames/$name');
    if (d.existsSync()) d.deleteSync(recursive: true);
    d.createSync(recursive: true);
  }
  final WidgetTester t;
  final String name;
  final double ratio;
  final int dtMs;
  int _n = 0;

  String _path(int i) =>
      '$_out/frames/$name/f${i.toString().padLeft(4, '0')}.png';

  Future<void> frame() => _png(t, _path(_n++), ratio);

  /// [frames] frames of app time, letting real async work through.
  Future<void> run(int frames) async {
    for (var i = 0; i < frames; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 4)));
      await t.pump(Duration(milliseconds: dtMs));
      await frame();
    }
  }

  /// Repeats the last frame (nothing moves).
  void hold(int frames) {
    final last = File(_path(_n - 1));
    for (var i = 0; i < frames; i++) {
      last.copySync(_path(_n++));
    }
  }

  Future<void> tap(Finder f, {int after = 18}) async {
    // Off screen (or under the tab bar): scroll it into view first.
    final r = t.getRect(f.first);
    if (r.top < _top + 40 || r.bottom > _logical.height - 90) {
      await t.ensureVisible(f.first);
      await run(8);
    }
    final p = t.getCenter(f.first);
    _touch.value = (p, false);
    await run(4);
    _touch.value = (p, true);
    await run(3);
    await t.tapAt(p);
    _touch.value = null;
    await run(after);
  }

  Future<void> drag(Finder f, Offset by, {int steps = 16, int after = 16}) async {
    var p = t.getCenter(f.first);
    _touch.value = (p, false);
    await run(3);
    final g = await t.startGesture(p);
    _touch.value = (p, true);
    for (var i = 0; i < steps; i++) {
      p += by / steps.toDouble();
      await g.moveTo(p);
      _touch.value = (p, true);
      await run(1);
    }
    await g.up();
    _touch.value = null;
    await run(after);
  }

  /// Waits for [f] without recording the wait (loading is not shown).
  Future<void> until(Finder f) => _until(t, f);

  Future<void> type(Finder f, String text) async {
    await tap(f, after: 4);
    for (var i = 1; i <= text.length; i++) {
      await t.enterText(f.first, text.substring(0, i));
      await run(2);
    }
  }
}

/// A bottom tab; the label text can also appear inside a screen.
Finder _nav(String label) => find.text(label).last;

// ── Setup ────────────────────────────────────────────────────────────

Future<void> _boot(WidgetTester t, AppPalette palette,
    {bool seed = true, String lang = 'en'}) async {
  t.view.physicalSize = _logical * _dpr;
  t.view.devicePixelRatio = _dpr;
  t.view.padding = const FakeViewPadding(top: _top * _dpr, bottom: _bottom * _dpr);
  addTearDown(t.view.reset);
  // Calendar / Reminders answer as on a phone where the user tapped Add.
  t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.playground.tracker/calendar'),
      (call) async => 'saved');
  await t.runAsync(() async {
    await _font('Archivo', [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'])
        'assets/fonts/Archivo-$w.ttf'
    ]);
    await _font('MaterialIcons',
        ['$_sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    if (seed) {
      await _seed();
    } else {
      await DatabaseHelper.resetForTests();
    }
    await AppSettings.instance.load();
    await AppSettings.instance.setPalette(palette);
    await AppSettings.instance.setLanguage(lang);
    await AppSettings.instance.setUse24h(true);
    await AppSettings.instance.setEuDate(true);
  });
  await t.pumpWidget(const _Stage());
  await settle(t);
  // The first frame after boot can miss the loaded data; open Today again.
  if (seed) {
    final l = lookupAppLocalizations(Locale(lang));
    await t.tap(_nav(l.today.toUpperCase()));
    await until(t, find.text(l.recap.toUpperCase()));
  } else {
    await settle(t, 20);
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseHelper.databasePathOverride = inMemoryDatabasePath;
  });

  Finder text(String s) => find.text(s).last;

  // ── App Store screens (1320 x 2868) ────────────────────────────────

  testWidgets('screens', (t) async {
    await _boot(t, AppPalette.swingLight);
    await shot(t, '01-today');

    await t.tap(find.text('EVENING'));
    await settle(t);
    await t.tap(find.text('BUSY'));
    await shot(t, '02-visit');
    await t.tap(find.text('Cancel'));
    await settle(t);

    await t.tap(_nav('HISTORY'));
    await settle(t);
    await t.tap(find.byIcon(Icons.chevron_left).first);
    await shot(t, '03-month');
    // Start the stats screenshot at "Who took them", under the tabs.
    final y = t.getTopLeft(find.text('WHO TOOK THEM')).dy;
    await t.drag(find.byType(Scrollable).first, Offset(0, -(y - 236)));
    await shot(t, '04-stats');

    await t.tap(_nav('TODAY'));
    await until(t, find.text('RECAP'));
    await t.tap(find.text('RECAP'));
    await shot(t, '05-recap');
    await t.tap(find.byType(BackButton).last);
    await settle(t);

    await t.tap(_nav('PLANS'));
    await settle(t);
    await t.tap(find.text('Football').first);
    await shot(t, '06-plan');
  });

  // Today in other looks, for the themes screenshot.
  for (final (palette, name) in [
    (AppPalette.swingDark, 'swing-dark'),
    (AppPalette.modernistLight, 'modernist-light'),
    (AppPalette.whiteOnBlack, 'white-on-black'),
    (AppPalette.custom, 'my-colors'),
  ]) {
    testWidgets('theme $name', (t) async {
      await _boot(t, palette);
      if (palette == AppPalette.custom) {
        await t.runAsync(() => AppSettings.instance.setCustomColors(
            bg: const Color(0xFF1B2333),
            txt: const Color(0xFFF4EFE6),
            accent: const Color(0xFFFFB31F)));
      }
      await shot(t, 'theme-$name');
    });
  }

  testWidgets('screen welcome', (t) async {
    await _boot(t, AppPalette.swingLight, seed: false);
    await shot(t, '08-welcome');
  });

  // ── GIFs (frames at 1.25x, 25 fps) ─────────────────────────────────

  testWidgets('gif log-visit', (t) async {
    await _boot(t, AppPalette.swingLight);
    final r = Rec(t, 'log-visit', ratio: 1.25);
    await r.run(1);
    r.hold(20);
    await r.tap(find.text('EVENING'), after: 16);
    await r.tap(text('Dad'), after: 10);
    await r.tap(text('1.5h'), after: 12);
    await r.tap(find.text('SAVE VISIT'), after: 24);
    r.hold(40);
  });

  testWidgets('gif new-plan', (t) async {
    await _boot(t, AppPalette.swingLight);
    final r = Rec(t, 'new-plan', ratio: 1.25);
    await r.run(1);
    await r.tap(_nav('PLANS'), after: 8);
    r.hold(10);
    await r.tap(find.byIcon(Icons.add).first, after: 14);
    await r.type(find.byType(TextField).first, 'Ballet');
    FocusManager.instance.primaryFocus?.unfocus();
    await r.run(4);
    await r.tap(text('Sat'), after: 6);
    await r.tap(text('Evening'), after: 6);
    await r.tap(text('Mia'), after: 8);
    await r.drag(find.text('WHEN?'), const Offset(0, -420), steps: 14, after: 8);
    await r.tap(find.byType(SquareSwitch).first, after: 10);
    await r.drag(find.text('WHEN?'), const Offset(0, -380), steps: 12, after: 8);
    await r.tap(text('Reminders'), after: 10);
    await r.tap(find.text('Save'), after: 30);
    r.hold(36);
  });

  testWidgets('gif themes', (t) async {
    await _boot(t, AppPalette.swingLight);
    final r = Rec(t, 'themes', ratio: 1.25);
    await r.run(1);
    await r.tap(_nav('SETTINGS'), after: 8);
    await r.tap(find.text('Language, date & theme'), after: 14);
    // The language list comes first; bring the themes up.
    await r.drag(find.text('Phone language'), const Offset(0, -380),
        steps: 14, after: 8);
    for (final name in [
      'Swing dark',
      'Modernist light',
      'Modernist dark',
      'White on black',
      'Black on white',
    ]) {
      await r.tap(find.text(name), after: 6);
      r.hold(12);
    }
    await r.tap(find.text('My colors'), after: 8);
    r.hold(6);
    await r.tap(find.text('Edit my colors'), after: 14);
    for (final hex in ['#8E2C48', '#00897B']) {
      await r.tap(find.bySemanticsLabel(hex).last, after: 6);
      r.hold(8);
    }
    await r.tap(find.byType(BackButton), after: 12);
    await r.tap(find.text('Swing light'), after: 8);
    r.hold(30);
  });

  testWidgets('gif history', (t) async {
    await _boot(t, AppPalette.swingLight);
    final r = Rec(t, 'history', ratio: 1.25);
    await r.run(1);
    await r.tap(_nav('HISTORY'), after: 12);
    await r.tap(find.byIcon(Icons.chevron_left).first, after: 10);
    r.hold(16);
    await r.drag(find.text('WHO TOOK THEM'), const Offset(0, -560), steps: 28, after: 8);
    r.hold(20);
    await r.drag(find.text('WHO TOOK THEM'), const Offset(0, 560), steps: 20, after: 6);
    await r.tap(_nav('TODAY'), after: 2);
    await r.until(find.text('RECAP'));
    await r.run(6);
    await r.tap(find.text('RECAP'), after: 16);
    r.hold(24);
    await r.tap(find.text('This month'), after: 10);
    r.hold(30);
  });

  testWidgets('gif onboarding', (t) async {
    await _boot(t, AppPalette.swingLight, seed: false);
    final r = Rec(t, 'onboarding', ratio: 1.25);
    final next = find.textContaining(
        RegExp('^(GET STARTED|CONTINUE|SKIP FOR NOW|START USING THE APP)\$'));
    Future<void> names(List<String> list) async {
      for (var i = 0; i < list.length; i++) {
        await r.type(find.byType(TextField).at(i), list[i]);
      }
      FocusManager.instance.primaryFocus?.unfocus();
      await r.run(6);
    }

    await r.run(1);
    r.hold(24);
    await r.tap(next, after: 14); // welcome
    await names(['Mom', 'Dad']);
    await r.tap(next, after: 14); // parents
    await names(['Mia', 'Leo']);
    await r.tap(next, after: 14); // kids
    await r.tap(find.byType(SquareSwitch).first, after: 12); // a reminder
    r.hold(8);
    await r.tap(next, after: 14); // reminders
    r.hold(8);
    await r.tap(next, after: 14); // plans: skip for now
    await r.tap(find.text('Swing dark'), after: 8);
    r.hold(10);
    await r.tap(find.text('Swing light'), after: 8);
    r.hold(6);
    expect(find.text('START USING THE APP'), findsOneWidget);
    await r.tap(next, after: 4);
    await r.until(find.text('RECAP'));
    await r.run(10);
    r.hold(30);
  });

  // ── Every language: the main screens at 1x, for checking translations ──
  // (an overflowing text fails the test, so these double as a layout check)

  Future<void> small(WidgetTester t, String lang, String name) async {
    await settle(t);
    await _png(t, '$_out/lang/$lang/$name.png', 1);
  }

  for (final lang in ['en', 'es', 'de', 'bs', 'cs']) {
    testWidgets('lang $lang', (t) async {
      final l = lookupAppLocalizations(Locale(lang));
      await _boot(t, AppPalette.swingLight, lang: lang);
      await small(t, lang, '01-today');
      await t.tap(find.text(l.evening.toUpperCase()));
      await small(t, lang, '02-visit');
      await t.tap(find.text(l.cancel).first);
      await settle(t);
      await t.tap(_nav(l.history.toUpperCase()));
      await settle(t);
      await t.tap(find.byIcon(Icons.chevron_left).first);
      await small(t, lang, '03-history');
      final y = t.getTopLeft(find.text(l.whoTookThem.toUpperCase())).dy;
      await t.drag(find.byType(Scrollable).first, Offset(0, -(y - 236)));
      await small(t, lang, '04-stats');
      await t.tap(_nav(l.plans.toUpperCase()));
      await settle(t);
      await small(t, lang, '05-plans');
      await t.tap(find.text('Football').first);
      await small(t, lang, '06-plan');
      await t.tap(find.byType(BackButton).last);
      await settle(t);
      await t.tap(find.byIcon(Icons.add).first);
      await small(t, lang, '07-new-plan');
      await t.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await small(t, lang, '08-new-plan-2');
      await t.tap(find.byType(BackButton).last);
      await settle(t);
      await t.tap(_nav(l.settings.toUpperCase()));
      await small(t, lang, '09-settings');
      await t.tap(find.text(l.languageDateTheme));
      await small(t, lang, '10-display');
      await t.tap(find.byType(BackButton).last);
      await settle(t);
      await t.tap(find.text(l.remindersSetting).first);
      await small(t, lang, '11-reminders');
      await t.tap(find.byType(BackButton).last);
      await settle(t);
      await t.tap(_nav(l.today.toUpperCase()));
      await until(t, find.text(l.recap.toUpperCase()));
      await t.tap(find.text(l.recap.toUpperCase()));
      await small(t, lang, '12-recap');
    });

    testWidgets('lang $lang onboarding', (t) async {
      final l = lookupAppLocalizations(Locale(lang));
      await _boot(t, AppPalette.swingLight, seed: false, lang: lang);
      Future<void> next() async {
        await t.tap(find.textContaining(RegExp('^(${[
          l.getStarted, l.continueLabel, l.skipForNow
        ].map((x) => RegExp.escape(x.toUpperCase())).join('|')})\$')));
        await settle(t);
      }

      await small(t, lang, 'o1-welcome');
      await next();
      await t.enterText(find.byType(TextField).at(0), l.sampleMom);
      await small(t, lang, 'o2-parents');
      await next();
      await t.enterText(find.byType(TextField).at(0), 'Mia');
      await small(t, lang, 'o3-kids');
      await next();
      await small(t, lang, 'o4-reminders');
      await next();
      await small(t, lang, 'o5-plans');
      await next();
      await small(t, lang, 'o6-look');
    });
  }
}
