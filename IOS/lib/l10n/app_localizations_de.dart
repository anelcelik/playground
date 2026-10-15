// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get reasonRain => 'Regen';

  @override
  String get reasonSick => 'Krank';

  @override
  String get reasonTooLate => 'Zu spät';

  @override
  String get reasonBusy => 'Keine Zeit';

  @override
  String get reasonCancelled => 'Abgesagt';

  @override
  String get reasonOther => 'Sonstiges';

  @override
  String get today => 'Heute';

  @override
  String get history => 'Verlauf';

  @override
  String get plans => 'Pläne';

  @override
  String get settings => 'Einstellungen';

  @override
  String get visitLogged => 'Besuch eingetragen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get recap => 'Rückblick';

  @override
  String get yesterday => 'Gestern';

  @override
  String get addAnother => 'Noch einen eintragen';

  @override
  String get logAVisit => 'Besuch eintragen';

  @override
  String get sameAsUsual => 'Wie immer';

  @override
  String get morning => 'Vormittag';

  @override
  String get evening => 'Nachmittag';

  @override
  String get nobodyWentToday => 'Heute war niemand draußen';

  @override
  String get nobodyWent => 'Niemand war draußen';

  @override
  String get onVacation => 'Im Urlaub';

  @override
  String get notLogged => 'Nicht eingetragen';

  @override
  String reasonTapToChange(String reason) {
    return '$reason · tippen zum Ändern';
  }

  @override
  String get tapToChange => 'Tippen zum Ändern';

  @override
  String get plannedForToday => 'Für heute geplant';

  @override
  String get planned => 'Geplant';

  @override
  String doneOfTotal(int done, int total) {
    return '$done von $total erledigt';
  }

  @override
  String get confirmedTapToEdit => 'Bestätigt · tippen zum Bearbeiten';

  @override
  String skippedBecause(String reason) {
    return 'Ausgelassen · $reason';
  }

  @override
  String get skipped => 'Ausgelassen';

  @override
  String get missed => 'Verpasst';

  @override
  String get done => 'Erledigt';

  @override
  String get skip => 'Auslassen';

  @override
  String get whySkip => 'Warum auslassen?';

  @override
  String whySkipHint(String title) {
    return 'Wähle oder schreib, warum „$title“ nicht stattfand.';
  }

  @override
  String get addActivity => 'Aktivität hinzufügen';

  @override
  String get addActivityHint => 'z. B. Sandkasten';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get morningVisit => 'Besuch am Vormittag';

  @override
  String get eveningVisit => 'Besuch am Nachmittag';

  @override
  String get save => 'Sichern';

  @override
  String get whoWent => 'Wer war dabei';

  @override
  String whyDidntGo(String names) {
    return 'Warum war $names nicht dabei?  ·  optional';
  }

  @override
  String get kids => 'Kinder';

  @override
  String get howLong => 'Wie lange';

  @override
  String get activitiesOptional => 'Aktivitäten  ·  optional';

  @override
  String get addChip => '+ Hinzufügen';

  @override
  String get onlyWhoWentRequired => 'Nur „Wer war dabei“ ist Pflicht.';

  @override
  String get prefilledMorning => 'Vom letzten Besuch am Vormittag übernommen.';

  @override
  String get prefilledEvening => 'Vom letzten Besuch am Nachmittag übernommen.';

  @override
  String get updateVisit => 'Besuch aktualisieren';

  @override
  String get saveVisit => 'Besuch sichern';

  @override
  String get whyNot => 'Warum nicht?';

  @override
  String get whyNotHint =>
      'Wähle oder schreib einen Grund, um den Tag als „niemand war draußen“ zu sichern.';

  @override
  String get writeYourOwn => '+ Eigenen schreiben';

  @override
  String get typeReasonHint => 'z. B. Oma zu Besuch';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get changeReason => 'Grund ändern';

  @override
  String get deleteEntry => 'Eintrag löschen';

  @override
  String get deleteEntryQuestion => 'Eintrag löschen?';

  @override
  String deleteEntryBody(String date) {
    return '$date: Er wird auch auf synchronisierten Geräten gelöscht.';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get entryDeleted => 'Eintrag gelöscht';

  @override
  String get undo => 'Rückgängig';

  @override
  String get vacation => 'Urlaub';

  @override
  String absentDidntGo(String names, String reasons) {
    return '$names war nicht dabei · $reasons';
  }

  @override
  String get selectWhoWent => 'Wähle, wer dabei war';

  @override
  String get editEntryTitle => 'Eintrag bearbeiten';

  @override
  String get whoWentQ => 'Wer war dabei?';

  @override
  String get whenQ => 'Wann?';

  @override
  String get howLongQ => 'Wie lange?';

  @override
  String get whichKidsQ => 'Welche Kinder?';

  @override
  String get activities => 'Aktivitäten';

  @override
  String get addActivityEllipsis => 'Aktivität hinzufügen…';

  @override
  String get log => 'Protokoll';

  @override
  String get logEmpty =>
      'Noch nichts eingetragen. Besuche, die du unter Heute einträgst, erscheinen hier, die neuesten zuerst.';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get thisYear => 'Dieses Jahr';

  @override
  String playgroundVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spielplatzbesuche',
      one: 'Spielplatzbesuch',
    );
    return '$_temp0';
  }

  @override
  String outsideAsFamily(String time) {
    return '$time draußen als Familie';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get longestStreak => 'Längste Serie';

  @override
  String get topActivity => 'Liebste Aktivität';

  @override
  String get wentTheMost => 'Am häufigsten dabei';

  @override
  String kidOutsideMost(String name) {
    return '$name war am meisten draußen';
  }

  @override
  String get taglineLots => 'Das ist eine Menge frische Luft. Super!';

  @override
  String taglineSolid(String period) {
    return '$period: ordentlich frische Luft. Weiter so!';
  }

  @override
  String get taglineEvery => 'Jeder Besuch zählt. Auf viele weitere!';

  @override
  String recapEmpty(String period) {
    return 'Noch nichts eingetragen für $period';
  }

  @override
  String get recapEmptyHint => 'Trag einen Besuch ein, dann erscheint er hier.';

  @override
  String get allTime => 'Gesamt';

  @override
  String get customiseDashboard => 'Verlauf anpassen';

  @override
  String get week => 'Woche';

  @override
  String get month => 'Monat';

  @override
  String get year => 'Jahr';

  @override
  String get all => 'Alle';

  @override
  String get whoTookThem => 'Wer war mit ihnen draußen';

  @override
  String get nobodyLoggedYet => 'Noch niemand eingetragen';

  @override
  String get kidsOutside => 'Kinder draußen';

  @override
  String get noKidsLoggedYet => 'Noch keine Kinder eingetragen';

  @override
  String get morningEvening => 'Vormittag / Nachmittag';

  @override
  String get noVisitsThisPeriod => 'Keine Besuche in diesem Zeitraum';

  @override
  String visitsInPeriod(String period) {
    return 'Besuche · $period';
  }

  @override
  String get outside => 'Draußen';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get oneSquarePerDayLower => 'ein Feld pro Tag';

  @override
  String get oneSquarePerMonthLower => 'ein Feld pro Monat';

  @override
  String get legendBusy => 'Viel';

  @override
  String get legendBoth => 'Beide';

  @override
  String get legendSome => 'Etwas';

  @override
  String get legendOne => 'Einer';

  @override
  String get legendNone => 'Keiner';

  @override
  String get mostPlayed => 'Am meisten gespielt';

  @override
  String get noActivitiesLoggedYet => 'Noch keine Aktivitäten eingetragen';

  @override
  String get timeAndMissedDays => 'Zeit & ausgefallene Tage';

  @override
  String get averageVisit => 'Durchschnittlicher Besuch';

  @override
  String get whyNobodyWent => 'Warum niemand draußen war';

  @override
  String get noMissedDays => 'Keine ausgefallenen Tage in diesem Zeitraum';

  @override
  String get noReasonsLoggedYet => 'Noch keine Gründe eingetragen';

  @override
  String get customiseDashboardTitle => 'Verlauf anpassen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get dragToReorder =>
      'Ziehen zum Sortieren  ·  Schalter zum Ein- und Ausblenden';

  @override
  String get oneSquarePerDay => 'Ein Feld pro Tag';

  @override
  String onceOn(String date) {
    return 'Einmalig · $date';
  }

  @override
  String get noDays => 'Keine Tage';

  @override
  String get everyDay => 'Jeden Tag';

  @override
  String get weekdays => 'Werktags';

  @override
  String get weekends => 'Am Wochenende';

  @override
  String get addedToReminders => 'Zu Erinnerungen hinzugefügt';

  @override
  String get addedToCalendar => 'Zum Kalender hinzugefügt';

  @override
  String get remindersDenied =>
      'Der Zugriff auf Erinnerungen ist aus. Erlaube ihn in den iPhone-Einstellungen.';

  @override
  String get calendarDenied =>
      'Der Zugriff auf den Kalender ist aus. Erlaube ihn in den iPhone-Einstellungen.';

  @override
  String get planNoUpcomingDay =>
      'Dieser Plan hat keinen kommenden Tag zum Hinzufügen';

  @override
  String get remindersUnavailable => 'Erinnerungen gibt es nur auf dem iPhone';

  @override
  String get calendarUnavailable => 'Den Kalender gibt es nur auf dem iPhone';

  @override
  String get remindersError =>
      'Konnte nicht zu Erinnerungen hinzugefügt werden';

  @override
  String get calendarError => 'Konnte nicht zum Kalender hinzugefügt werden';

  @override
  String withKids(String names) {
    return 'Mit $names';
  }

  @override
  String get editPlan => 'Plan bearbeiten';

  @override
  String get addToCalendar => 'Zum Kalender hinzufügen';

  @override
  String get addToCalendarSub =>
      'Öffnet den iPhone-Kalender: Gäste dort einladen';

  @override
  String get addToReminders => 'Zu Erinnerungen hinzufügen';

  @override
  String get addToRemindersSub =>
      'Eine Erinnerung mit Hinweis zur Zeit des Plans';

  @override
  String get todayNotDoneYet => 'Heute · noch nicht erledigt';

  @override
  String get planNoDaysYet =>
      'Noch keine Tage. Sie erscheinen hier, sobald der Plan begonnen hat.';

  @override
  String get deletePlanQuestion => 'Plan löschen?';

  @override
  String deletePlanBody(String title) {
    return '„$title“ und sein ganzer Verlauf werden endgültig gelöscht.';
  }

  @override
  String get newPlan => 'Neuer Plan';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String reminderAt(String time) {
    return 'Erinnerung $time';
  }

  @override
  String get tapForHistory => 'Tippen für Verlauf, Kalender und Erinnerungen';

  @override
  String get deactivate => 'Deaktivieren';

  @override
  String get activate => 'Aktivieren';

  @override
  String get noPlansYet => 'Noch keine Pläne';

  @override
  String get noPlansHint =>
      'Füge Pläne hinzu, die sich an bestimmten Tagen wiederholen oder einmal stattfinden.\nSie erscheinen unter Heute.';

  @override
  String get addFirstPlan => 'Ersten Plan hinzufügen';

  @override
  String get enterTitle => 'Gib einen Titel ein';

  @override
  String get pickADate => 'Wähle ein Datum';

  @override
  String get selectAtLeastOneDay => 'Wähle mindestens einen Tag';

  @override
  String get notSet => 'Nicht gesetzt';

  @override
  String get planTitle => 'Titel';

  @override
  String get planTitleHint => 'z. B. Fußball';

  @override
  String get howOftenQ => 'Wie oft?';

  @override
  String get repeats => 'Wiederholt sich';

  @override
  String get oneTime => 'Einmalig';

  @override
  String dateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get repeatOn => 'Wiederholen am';

  @override
  String get dateRangeOptional => 'Zeitraum (optional)';

  @override
  String fromDate(String date) {
    return 'Von: $date';
  }

  @override
  String toDate(String date) {
    return 'Bis: $date';
  }

  @override
  String get clearDates => 'Daten löschen';

  @override
  String get reminderNotification => 'Erinnerungsmitteilung';

  @override
  String get reminderNotificationSub =>
      'An den Tagen des Plans eine Mitteilung senden';

  @override
  String notifyAt(String time) {
    return 'Erinnern um  $time';
  }

  @override
  String get customMessageHint =>
      'Eigene Nachricht (optional)\nz. B. Zeit zum Rausgehen!';

  @override
  String get leaveEmptyDefault => 'Leer lassen für die Standardnachricht.';

  @override
  String get timeAlreadyPassed =>
      'Diese Uhrzeit ist schon vorbei, daher kommt keine Mitteilung. Wähle eine spätere Uhrzeit.';

  @override
  String get alsoAddTo => 'Auch hinzufügen zu (optional)';

  @override
  String get calendar => 'Kalender';

  @override
  String get remindersApp => 'Erinnerungen';

  @override
  String get alsoAddToHint =>
      'Beim Sichern: Der Kalender öffnet sich mit dem ausgefüllten Plan, damit du Leute einladen kannst. Erinnerungen bekommt den Plan mit einem Hinweis zu seiner Zeit.';

  @override
  String get inactivePlansHidden =>
      'Inaktive Pläne erscheinen nicht unter Heute';

  @override
  String get themeModernistLight => 'Modernist hell';

  @override
  String get themeModernistLightSub =>
      'Rot und Schwarz auf Papier, das Original';

  @override
  String get themeModernistDark => 'Modernist dunkel';

  @override
  String get themeModernistDarkSub => 'Koralle auf warmem Schwarz';

  @override
  String get themeSwingLight => 'Swing hell';

  @override
  String get themeSwingLightSub => 'Dunkelgrün und Orange auf Sonnengelb';

  @override
  String get themeSwingDark => 'Swing dunkel';

  @override
  String get themeSwingDarkSub => 'Sonnengelb auf Dunkelgrün';

  @override
  String get themeBlackOnWhite => 'Schwarz auf Weiß';

  @override
  String get themeBlackOnWhiteSub => 'Schlichtes Schwarz auf Weiß';

  @override
  String get themeWhiteOnBlack => 'Weiß auf Schwarz';

  @override
  String get themeWhiteOnBlackSub => 'Schlichtes Weiß auf Schwarz';

  @override
  String get themeMyColors => 'Meine Farben';

  @override
  String get themeMyColorsSub => 'Eigener Hintergrund, Text und Akzent';

  @override
  String get family => 'Familie';

  @override
  String get parentsAndKids => 'Eltern & Kinder';

  @override
  String get familySync => 'Familien-Sync';

  @override
  String get familySyncSub => 'Über Apple-IDs hinweg teilen';

  @override
  String get app => 'App';

  @override
  String get remindersSetting => 'Erinnerungen';

  @override
  String get languageDateTheme => 'Sprache, Datum & Design';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get noDataCollected => 'Keine Daten erfasst';

  @override
  String get yourData => 'Deine Daten';

  @override
  String get logSub => 'Jeder Besuch, die neuesten zuerst';

  @override
  String get deleteAllData => 'Alle Daten löschen';

  @override
  String get deleteAllDataSub => 'Auf diesem iPhone und in iCloud';

  @override
  String get aboutNote =>
      'Playground Tracker ist ein einmaliger Kauf im App Store. Kein Abo, kein Konto, keine Werbung. Dein Protokoll bleibt auf deinen Geräten und wird über deine eigene iCloud synchronisiert.';

  @override
  String get deleteAllDataQuestion => 'Alle Daten löschen?';

  @override
  String get deleteAllDataBody =>
      'Jeder Besuch, Plan, Name und jede Einstellung wird von diesem iPhone und aus deiner iCloud gelöscht. Wenn du das Protokoll mit deiner Familie teilst, verliert sie es auch. Das lässt sich nicht rückgängig machen.';

  @override
  String get deleteEverything => 'Alles löschen';

  @override
  String get deleting => 'Wird gelöscht…';

  @override
  String get nothingDeleted => 'Nichts wurde gelöscht';

  @override
  String get nothingDeletedBody =>
      'iCloud war nicht erreichbar, deshalb sind deine Daten unverändert geblieben (sonst würde der Sync sie zurückbringen). Versuch es noch einmal, wenn du online bist.';

  @override
  String get ok => 'OK';

  @override
  String get notificationsTitle => 'Erinnerungen';

  @override
  String get outdoorReminder => 'Erinnerung zum Rausgehen';

  @override
  String get outdoorReminderSub =>
      'Warst du heute mit den Kindern draußen? Kommt einmal am Tag zu der Uhrzeit, die du wählst.';

  @override
  String get logReminder => 'Erinnerung zum Eintragen';

  @override
  String get logReminderSub =>
      'Vergiss nicht, den heutigen Spielplatzbesuch einzutragen. Kommt einmal am Tag zu der Uhrzeit, die du wählst.';

  @override
  String everyDayAt(String time) {
    return 'Jeden Tag um  $time';
  }

  @override
  String get notificationsBlocked =>
      'Mitteilungen sind blockiert. Öffne Einstellungen › Playground Tracker › Mitteilungen und erlaube sie.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get notificationsLocalNote =>
      'Mitteilungen sind lokal, kein Internet nötig. Jede Person in der Familie stellt ihre eigenen Zeiten auf ihrem eigenen Handy ein.';

  @override
  String get language => 'Sprache';

  @override
  String get phoneLanguage => 'Sprache des Handys';

  @override
  String get colorTheme => 'Farbdesign';

  @override
  String get editMyColors => 'Meine Farben bearbeiten';

  @override
  String get timeFormat => 'Uhrzeitformat';

  @override
  String get hour12 => '12 Stunden';

  @override
  String get hour24 => '24 Stunden';

  @override
  String get changesApplyImmediately =>
      'Änderungen gelten sofort in der ganzen App.';

  @override
  String contrastTextWarning(String ratio) {
    return 'Text ist auf diesem Hintergrund schwer lesbar: Kontrast $ratio:1, ideal sind 4,5:1 oder mehr.';
  }

  @override
  String contrastAccentWarning(String ratio) {
    return 'Der Akzent ist auf diesem Hintergrund schwer zu sehen: Kontrast $ratio:1, ideal sind 3:1 oder mehr.';
  }

  @override
  String get sampleMom => 'Mama';

  @override
  String get sampleDad => 'Papa';

  @override
  String get colorBackground => 'Hintergrund';

  @override
  String get colorText => 'Text';

  @override
  String get colorAccent => 'Akzent (Tasten, Auswahl)';

  @override
  String get notifOutdoorTitle => 'Spielplatz-Erinnerung';

  @override
  String get notifOutdoorBody => 'Warst du heute mit den Kindern draußen?';

  @override
  String get notifLogTitle => 'Trag eure Zeit draußen ein';

  @override
  String get notifLogBody =>
      'Vergiss nicht, den heutigen Spielplatzbesuch einzutragen.';

  @override
  String get notifPlanDefaultBody => 'Zeit für deinen Plan';

  @override
  String get addParentAndKid =>
      'Füge mindestens einen Elternteil und ein Kind hinzu';

  @override
  String get welcome => 'Willkommen';

  @override
  String get familyEditIntro =>
      'Aktualisiere deine Familienmitglieder. Vorhandene Einträge bleiben unverändert.';

  @override
  String get familySetupIntro =>
      'Lass uns deine Familie einrichten. Du kannst später jederzeit weitere Personen hinzufügen.';

  @override
  String get parentsGrandparents => 'Eltern / Großeltern';

  @override
  String get parentHint1 => 'z. B. Mama';

  @override
  String get parentHint2 => 'z. B. Papa';

  @override
  String get parentHintMore => 'Elternteil oder Großelternteil';

  @override
  String get addParent => '+ Erwachsenen hinzufügen';

  @override
  String get kidHint1 => 'z. B. Emma';

  @override
  String get kidHint2 => 'z. B. Tom';

  @override
  String get kidHintMore => 'Name des Kindes';

  @override
  String get addKid => '+ Kind hinzufügen';

  @override
  String get saveChanges => 'Änderungen sichern';

  @override
  String get saveAndStart => 'Sichern & loslegen';

  @override
  String minutesAgo(int count) {
    return 'vor $count Min.';
  }

  @override
  String hoursAgo(int count) {
    return 'vor $count Std.';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get removeAccessQuestion => 'Zugriff entfernen?';

  @override
  String removeAccessBody(String name) {
    return '$name synchronisiert nicht mehr mit diesem Protokoll. Vorhandene Einträge bleiben auf dem eigenen Handy.';
  }

  @override
  String get remove => 'Entfernen';

  @override
  String get couldNotRemove =>
      'Entfernen fehlgeschlagen. Versuch es noch einmal.';

  @override
  String get connectedUser => 'Verbundene Person';

  @override
  String get inviteSomeone => 'Jemanden einladen';

  @override
  String get inviteSub =>
      'Öffnet das iOS-Teilen-Menü: per Nachrichten, WhatsApp senden oder Link kopieren';

  @override
  String get connected => 'Verbunden';

  @override
  String lastSynced(String time) {
    return 'Zuletzt synchronisiert $time';
  }

  @override
  String get shareWithFamily => 'Mit der Familie teilen';

  @override
  String get shareWithFamilySub =>
      'Jede Person nutzt ihre eigene Apple-ID. Keine gemeinsamen Konten nötig.';

  @override
  String get owner => 'Eigentümer';

  @override
  String get invitePending => 'Einladung ausstehend…';

  @override
  String get you => 'Du';

  @override
  String get noOneConnected => 'Noch niemand verbunden';

  @override
  String get noOneConnectedHint =>
      'Tippe oben auf „Jemanden einladen“, um mit\ndeinem Partner oder deiner Familie zu teilen.';

  @override
  String get howItWorks => 'So funktioniert’s';

  @override
  String get howStep1 =>
      'Tippe auf „Jemanden einladen“ und das iOS-Teilen-Menü öffnet sich';

  @override
  String get howStep2 =>
      'Sende den Link per Nachrichten, WhatsApp oder kopiere ihn';

  @override
  String get howStep3 =>
      'Die andere Person tippt auf den Link, dann auf „Annehmen“. Fertig.';

  @override
  String get howStep4 => 'Beide Handys bleiben automatisch synchron';

  @override
  String get onbParentsTitle => 'Wer geht mit den Kindern raus?';

  @override
  String get onbParentsNote =>
      'Echte Namen sind nicht nötig: Mama und Papa, Spitznamen oder Initialen funktionieren genauso. Die Namen erscheinen nur in der App.';

  @override
  String get onbKidsTitle => 'Und die Kinder?';

  @override
  String get onbKidHint1 => 'z. B. Böhnchen';

  @override
  String get onbKidHint2 => 'z. B. Tiger';

  @override
  String get onbKidsNote =>
      'Spitznamen sind auch hier perfekt. Alles bleibt auf deinem iPhone und in deiner eigenen iCloud, nie bei uns.';

  @override
  String get getStarted => 'Los geht’s';

  @override
  String get startUsingApp => 'App benutzen';

  @override
  String get skipForNow => 'Erst mal überspringen';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get onbWelcome1 =>
      'Ein schnelles Protokoll eurer Zeit draußen: wer mit den Kindern draußen war, wie lange und was sie gemacht haben.';

  @override
  String get onbWelcome2 =>
      'In den nächsten Schritten richtest du deine Familie, optionale Erinnerungen und Pläne ein. Das dauert etwa eine Minute, und alles lässt sich später in den Einstellungen ändern.';

  @override
  String get onbWelcomeNote =>
      'Kein Konto, keine Werbung, kein Tracking. Dein Protokoll bleibt auf deinem iPhone und in deiner eigenen iCloud.';

  @override
  String get name => 'Name';

  @override
  String get addAnotherChip => '+ Weitere hinzufügen';

  @override
  String get onbRemindersIntro =>
      'Optional. Ein kleiner Anstoß einmal am Tag, zu einer Uhrzeit deiner Wahl. iOS fragt nach der Erlaubnis, wenn du eine einschaltest.';

  @override
  String get onbReminderOutside => 'Zeit zum Rausgehen';

  @override
  String get onbReminderLog => 'Heutigen Besuch eintragen';

  @override
  String get onbRemindersLater =>
      'Du kannst das jederzeit unter Einstellungen › Erinnerungen ändern.';

  @override
  String everyDayAtChange(String time) {
    return 'Jeden Tag um $time · ändern';
  }

  @override
  String get onbPlansIntro =>
      'Optional. Fußball jeden Montag, Schwimmen am Samstag, ein Kindergeburtstag nächste Woche: Pläne erscheinen unter Heute, bereit zum Abhaken, und können dich erinnern.';

  @override
  String get addAPlan => 'Plan hinzufügen';

  @override
  String get addAnotherPlan => 'Weiteren Plan hinzufügen';

  @override
  String get onbPlansLater =>
      'Du kannst jederzeit im Tab Pläne weitere hinzufügen.';

  @override
  String get onbLookTitle => 'Dein Look';

  @override
  String get onbLookIntro =>
      'Wähle ein Farbdesign oder gestalte dein eigenes. Du kannst es jederzeit in den Einstellungen ändern.';

  @override
  String get privInShortTitle => 'Kurz gesagt';

  @override
  String get privInShort =>
      'Playground Tracker erfasst keine personenbezogenen Daten. Es gibt kein Konto, keinen eigenen Server, keine Analyse, keine Werbung und kein Tracking. Der Entwickler kann dein Protokoll nicht sehen.';

  @override
  String get privStoresTitle => 'Was die App speichert';

  @override
  String get privStores =>
      'Die Namen der Eltern und Kinder, die du eingibst, deine Besuche (Datum, Vormittag oder Nachmittag, wer dabei war, welche Kinder, wie lange, Aktivitäten und jeden Grund, den du angibst), deine Pläne und wie sie liefen, sowie deine Einstellungen. Alles liegt im privaten Speicher der App auf deinem iPhone.';

  @override
  String get privICloudTitle => 'iCloud-Sync und Teilen mit der Familie';

  @override
  String get privICloud =>
      'Wenn du bei iCloud angemeldet bist, legt die App über Apples CloudKit eine Kopie in deiner eigenen privaten iCloud-Datenbank ab, damit alles auf deinen Geräten synchron bleibt. Wenn du Familienmitglieder per Link einlädst, können die eingeladenen Personen das geteilte Protokoll sehen und bearbeiten, bis du das Teilen beendest. iCloud-Daten verarbeitet Apple gemäß Apples Datenschutzrichtlinie; der Entwickler hat keinen Zugriff darauf.';

  @override
  String get privRemindersTitle => 'Erinnerungen';

  @override
  String get privReminders =>
      'Erinnerungsmitteilungen werden auf deinem iPhone geplant. Nichts davon wird irgendwohin gesendet. Die App fragt nur nach der Erlaubnis, wenn du eine Erinnerung einschaltest.';

  @override
  String get privCalendarTitle => 'Kalender und Erinnerungen';

  @override
  String get privCalendar =>
      '„Zum Kalender hinzufügen“ öffnet Apples eigenen Termin-Editor mit dem ausgefüllten Plan. Die App liest deinen Kalender nicht; der Termin wird nur gesichert, wenn du auf Hinzufügen tippst. „Zu Erinnerungen hinzufügen“ speichert den Plan als eine neue Erinnerung in deiner Erinnerungen-App. Die App liest deine Erinnerungen nicht und nichts wird irgendwohin gesendet.';

  @override
  String get privChildrenTitle => 'Kinder';

  @override
  String get privChildren =>
      'Die App ist für Eltern gedacht. Die Namen der Kinder bleiben auf deinem iPhone und in deiner eigenen iCloud. Nichts über Kinder wird an den Entwickler oder an andere gesendet.';

  @override
  String get privDeletingTitle => 'Deine Daten löschen';

  @override
  String get privDeleting =>
      'Einstellungen › Alle Daten löschen entfernt alles auf einmal, von deinem iPhone und aus deiner iCloud; wenn du das Protokoll mit deiner Familie teilst, wird es auch für sie entfernt. Du kannst auch jederzeit einzelne Einträge löschen, und wenn du die App löschst, wird alles auf dem iPhone Gespeicherte entfernt. Um das Teilen zu beenden, nutze Familien-Sync in den Einstellungen.';

  @override
  String get privChangesTitle => 'Änderungen';

  @override
  String get privChanges =>
      'Ändert sich diese Richtlinie, kommt die neue Fassung mit einem App-Update, und das Datum oben ändert sich.';

  @override
  String privacyEffective(String date) {
    return 'Gültig ab $date';
  }

  @override
  String get dashTapToChange => '— tippen zum Ändern';

  @override
  String get hour24Time => '24-Stunden-Format';

  @override
  String get justNow => 'gerade eben';

  @override
  String parentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erwachsene',
      one: '1 Erwachsener',
    );
    return '$_temp0';
  }

  @override
  String kidsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kinder',
      one: '1 Kind',
    );
    return '$_temp0';
  }

  @override
  String personRemoved(String name) {
    return '$name entfernt';
  }

  @override
  String get advanced => 'Erweitert';

  @override
  String get startTime => 'Beginn';

  @override
  String get endTime => 'Ende';

  @override
  String get endAfterStart => 'Das Ende muss nach dem Beginn liegen';

  @override
  String timeOutside(String time) {
    return '$time draußen';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tage in Folge',
      one: 'Tag in Folge',
    );
    return '$_temp0';
  }

  @override
  String get streakDoneToday => 'Für heute geschafft';

  @override
  String get streakKeepGoing => 'Geh heute raus, dann geht sie weiter';

  @override
  String get streakAtRisk =>
      'Gestern verpasst. Geh heute raus, sonst endet sie';

  @override
  String get streakStart => 'Geh heute raus und starte eine';

  @override
  String get streakRule =>
      'Die Serie zählt die Tage, an denen ihr draußen wart. Ein verpasster Tag wird verziehen, zwei hintereinander beenden sie. Urlaub pausiert sie.';

  @override
  String get goal => 'Ziel';

  @override
  String get setAGoal => 'Setz dir ein Ziel für draußen';

  @override
  String goalOf(String done, String target) {
    return '$done von $target';
  }

  @override
  String get goalReached => 'Ziel erreicht';

  @override
  String get goalOnTrack => 'Im Plan';

  @override
  String goalBehind(String time) {
    return '$time im Rückstand';
  }

  @override
  String get outdoorGoal => 'Ziel für draußen';

  @override
  String get goalPeriod => 'Zeitraum';

  @override
  String get hoursOutside => 'Stunden draußen';

  @override
  String get otherAmount => 'Eigene';

  @override
  String get hoursHint => 'Stunden, z. B. 12';

  @override
  String get goalNote =>
      'Zählt die Länge jedes eingetragenen Besuchs. Ein beliebtes Ziel sind 1000 Stunden im Jahr: etwa 2 Stunden 45 Minuten am Tag.';

  @override
  String get turnOffGoal => 'Ziel ausschalten';

  @override
  String get goalOff => 'Aus';

  @override
  String goalAWeek(String time) {
    return '$time pro Woche';
  }

  @override
  String goalAMonth(String time) {
    return '$time pro Monat';
  }

  @override
  String goalAYear(String time) {
    return '$time pro Jahr';
  }

  @override
  String get outdoorActivity => 'Aktivität draußen';

  @override
  String get outdoorActivitySub =>
      'Erledigt zählt als Zeit draußen. Für Dinge wie Klavierunterricht ausschalten.';
}
