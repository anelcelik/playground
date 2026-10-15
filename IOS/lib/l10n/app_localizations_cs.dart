// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get reasonRain => 'Déšť';

  @override
  String get reasonSick => 'Nemoc';

  @override
  String get reasonTooLate => 'Pozdě';

  @override
  String get reasonBusy => 'Nebyl čas';

  @override
  String get reasonCancelled => 'Zrušeno';

  @override
  String get reasonOther => 'Jiné';

  @override
  String get today => 'Dnes';

  @override
  String get history => 'Historie';

  @override
  String get plans => 'Plány';

  @override
  String get settings => 'Nastavení';

  @override
  String get visitLogged => 'Návštěva zapsána';

  @override
  String get edit => 'Upravit';

  @override
  String get recap => 'Shrnutí';

  @override
  String get yesterday => 'Včera';

  @override
  String get addAnother => 'Přidat další';

  @override
  String get logAVisit => 'Zapsat návštěvu';

  @override
  String get sameAsUsual => 'Jako obvykle';

  @override
  String get morning => 'Dopoledne';

  @override
  String get evening => 'Odpoledne';

  @override
  String get nobodyWentToday => 'Dnes nikdo nešel';

  @override
  String get nobodyWent => 'Nikdo nešel';

  @override
  String get onVacation => 'Na dovolené';

  @override
  String get notLogged => 'Nezapsáno';

  @override
  String reasonTapToChange(String reason) {
    return '$reason · klepnutím změníte';
  }

  @override
  String get tapToChange => 'Klepnutím změníte';

  @override
  String get plannedForToday => 'Plán na dnes';

  @override
  String get planned => 'Naplánováno';

  @override
  String doneOfTotal(int done, int total) {
    return 'Hotovo $done z $total';
  }

  @override
  String get confirmedTapToEdit => 'Potvrzeno · klepnutím upravíte';

  @override
  String skippedBecause(String reason) {
    return 'Vynecháno · $reason';
  }

  @override
  String get skipped => 'Vynecháno';

  @override
  String get missed => 'Zmeškáno';

  @override
  String get done => 'Hotovo';

  @override
  String get skip => 'Vynechat';

  @override
  String get whySkip => 'Proč vynechat?';

  @override
  String whySkipHint(String title) {
    return 'Vyberte nebo napište, proč se „$title“ nekonalo.';
  }

  @override
  String get addActivity => 'Přidat aktivitu';

  @override
  String get addActivityHint => 'např. Pískoviště';

  @override
  String get cancel => 'Zrušit';

  @override
  String get add => 'Přidat';

  @override
  String get morningVisit => 'Dopolední návštěva';

  @override
  String get eveningVisit => 'Odpolední návštěva';

  @override
  String get save => 'Uložit';

  @override
  String get whoWent => 'Kdo šel';

  @override
  String whyDidntGo(String names) {
    return 'Proč nešel/nešla $names?  ·  nepovinné';
  }

  @override
  String get kids => 'Děti';

  @override
  String get howLong => 'Jak dlouho';

  @override
  String get activitiesOptional => 'Aktivity  ·  nepovinné';

  @override
  String get addChip => '+ Přidat';

  @override
  String get onlyWhoWentRequired => 'Povinné je jen „kdo šel“.';

  @override
  String get prefilledMorning =>
      'Předvyplněno podle poslední dopolední návštěvy.';

  @override
  String get prefilledEvening =>
      'Předvyplněno podle poslední odpolední návštěvy.';

  @override
  String get updateVisit => 'Aktualizovat návštěvu';

  @override
  String get saveVisit => 'Uložit návštěvu';

  @override
  String get whyNot => 'Proč ne?';

  @override
  String get whyNotHint =>
      'Vyberte nebo napište důvod a den se uloží jako „nikdo nešel“.';

  @override
  String get writeYourOwn => '+ Napsat vlastní';

  @override
  String get typeReasonHint => 'např. Návštěva babičky';

  @override
  String get editEntry => 'Upravit záznam';

  @override
  String get changeReason => 'Změnit důvod';

  @override
  String get deleteEntry => 'Smazat záznam';

  @override
  String get deleteEntryQuestion => 'Smazat záznam?';

  @override
  String deleteEntryBody(String date) {
    return '$date: smaže se i na synchronizovaných zařízeních.';
  }

  @override
  String get delete => 'Smazat';

  @override
  String get entryDeleted => 'Záznam smazán';

  @override
  String get undo => 'Zpět';

  @override
  String get vacation => 'Dovolená';

  @override
  String absentDidntGo(String names, String reasons) {
    return '$names nešel/nešla · $reasons';
  }

  @override
  String get selectWhoWent => 'Vyberte, kdo šel';

  @override
  String get editEntryTitle => 'Upravit záznam';

  @override
  String get whoWentQ => 'Kdo šel?';

  @override
  String get whenQ => 'Kdy?';

  @override
  String get howLongQ => 'Jak dlouho?';

  @override
  String get whichKidsQ => 'Které děti?';

  @override
  String get activities => 'Aktivity';

  @override
  String get addActivityEllipsis => 'Přidat aktivitu…';

  @override
  String get log => 'Záznamy';

  @override
  String get logEmpty =>
      'Zatím nic zapsáno. Návštěvy, které zapíšete v sekci Dnes, se objeví tady, nejnovější nahoře.';

  @override
  String get thisMonth => 'Tento měsíc';

  @override
  String get thisYear => 'Tento rok';

  @override
  String playgroundVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'návštěv hřiště',
      few: 'návštěvy hřiště',
      one: 'návštěva hřiště',
    );
    return '$_temp0';
  }

  @override
  String outsideAsFamily(String time) {
    return '$time venku jako rodina';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní',
      few: '$count dny',
      one: '$count den',
    );
    return '$_temp0';
  }

  @override
  String get longestStreak => 'Nejdelší série';

  @override
  String get topActivity => 'Oblíbená aktivita';

  @override
  String get wentTheMost => 'Chodil/a nejčastěji';

  @override
  String kidOutsideMost(String name) {
    return '$name byl/a venku nejvíc';
  }

  @override
  String get taglineLots => 'To je spousta čerstvého vzduchu. Skvělá práce!';

  @override
  String taglineSolid(String period) {
    return '$period: pořádná porce venku. Jen tak dál!';
  }

  @override
  String get taglineEvery => 'Každá návštěva se počítá. Ať je jich víc.';

  @override
  String recapEmpty(String period) {
    return 'Za $period zatím nic zapsáno';
  }

  @override
  String get recapEmptyHint => 'Zapište návštěvu a objeví se tady.';

  @override
  String get allTime => 'Celkem';

  @override
  String get customiseDashboard => 'Upravit historii';

  @override
  String get week => 'Týden';

  @override
  String get month => 'Měsíc';

  @override
  String get year => 'Rok';

  @override
  String get all => 'Vše';

  @override
  String get whoTookThem => 'Kdo s nimi šel';

  @override
  String get nobodyLoggedYet => 'Zatím nikdo nezapsán';

  @override
  String get kidsOutside => 'Děti venku';

  @override
  String get noKidsLoggedYet => 'Zatím žádné děti nezapsány';

  @override
  String get morningEvening => 'Dopoledne / odpoledne';

  @override
  String get noVisitsThisPeriod => 'V tomto období žádné návštěvy';

  @override
  String visitsInPeriod(String period) {
    return 'Návštěvy · $period';
  }

  @override
  String get outside => 'Venku';

  @override
  String get thisWeek => 'Tento týden';

  @override
  String get oneSquarePerDayLower => 'jeden čtverec za den';

  @override
  String get oneSquarePerMonthLower => 'jeden čtverec za měsíc';

  @override
  String get legendBusy => 'Hodně';

  @override
  String get legendBoth => 'Oba';

  @override
  String get legendSome => 'Trochu';

  @override
  String get legendOne => 'Jeden';

  @override
  String get legendNone => 'Nikdo';

  @override
  String get mostPlayed => 'Nejčastější hry';

  @override
  String get noActivitiesLoggedYet => 'Zatím žádné aktivity nezapsány';

  @override
  String get timeAndMissedDays => 'Čas a vynechané dny';

  @override
  String get averageVisit => 'Průměrná návštěva';

  @override
  String get whyNobodyWent => 'Proč nikdo nešel';

  @override
  String get noMissedDays => 'V tomto období žádné vynechané dny';

  @override
  String get noReasonsLoggedYet => 'Zatím žádné důvody nezapsány';

  @override
  String get customiseDashboardTitle => 'Upravit historii';

  @override
  String get reset => 'Obnovit výchozí';

  @override
  String get dragToReorder =>
      'Přetažením změníte pořadí  ·  přepínačem zobrazíte či skryjete';

  @override
  String get oneSquarePerDay => 'Jeden čtverec za den';

  @override
  String onceOn(String date) {
    return 'Jednou · $date';
  }

  @override
  String get noDays => 'Žádné dny';

  @override
  String get everyDay => 'Každý den';

  @override
  String get weekdays => 'Ve všední dny';

  @override
  String get weekends => 'O víkendech';

  @override
  String get addedToReminders => 'Přidáno do Připomínek';

  @override
  String get addedToCalendar => 'Přidáno do kalendáře';

  @override
  String get remindersDenied =>
      'Přístup k Připomínkám je vypnutý. Povolte ho v Nastavení iPhonu.';

  @override
  String get calendarDenied =>
      'Přístup ke Kalendáři je vypnutý. Povolte ho v Nastavení iPhonu.';

  @override
  String get planNoUpcomingDay =>
      'Tento plán nemá žádný nadcházející den k přidání';

  @override
  String get remindersUnavailable => 'Připomínky jsou dostupné jen na iPhonu';

  @override
  String get calendarUnavailable => 'Kalendář je dostupný jen na iPhonu';

  @override
  String get remindersError => 'Do Připomínek se nepodařilo přidat';

  @override
  String get calendarError => 'Do Kalendáře se nepodařilo přidat';

  @override
  String withKids(String names) {
    return 'S: $names';
  }

  @override
  String get editPlan => 'Upravit plán';

  @override
  String get addToCalendar => 'Přidat do Kalendáře';

  @override
  String get addToCalendarSub =>
      'Otevře Kalendář v iPhonu: tam pozvete ostatní';

  @override
  String get addToReminders => 'Přidat do Připomínek';

  @override
  String get addToRemindersSub => 'Připomínka s upozorněním v čase plánu';

  @override
  String get todayNotDoneYet => 'Dnes · zatím nesplněno';

  @override
  String get planNoDaysYet =>
      'Zatím žádné dny. Objeví se tady, jakmile plán začne.';

  @override
  String get deletePlanQuestion => 'Smazat plán?';

  @override
  String deletePlanBody(String title) {
    return '„$title“ a celá jeho historie budou trvale smazány.';
  }

  @override
  String get newPlan => 'Nový plán';

  @override
  String get active => 'Aktivní';

  @override
  String get inactive => 'Neaktivní';

  @override
  String reminderAt(String time) {
    return 'Připomenutí $time';
  }

  @override
  String get tapForHistory =>
      'Klepnutím zobrazíte historii, Kalendář a Připomínky';

  @override
  String get deactivate => 'Deaktivovat';

  @override
  String get activate => 'Aktivovat';

  @override
  String get noPlansYet => 'Zatím žádné plány';

  @override
  String get noPlansHint =>
      'Přidejte plány, které se opakují v určité dny nebo proběhnou jednou.\nZobrazí se v sekci Dnes.';

  @override
  String get addFirstPlan => 'Přidat první plán';

  @override
  String get enterTitle => 'Zadejte název';

  @override
  String get pickADate => 'Vyberte datum';

  @override
  String get selectAtLeastOneDay => 'Vyberte alespoň jeden den';

  @override
  String get notSet => 'Nenastaveno';

  @override
  String get planTitle => 'Název';

  @override
  String get planTitleHint => 'např. Fotbal';

  @override
  String get howOftenQ => 'Jak často?';

  @override
  String get repeats => 'Opakuje se';

  @override
  String get oneTime => 'Jednou';

  @override
  String dateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get repeatOn => 'Opakovat v';

  @override
  String get dateRangeOptional => 'Období (nepovinné)';

  @override
  String fromDate(String date) {
    return 'Od: $date';
  }

  @override
  String toDate(String date) {
    return 'Do: $date';
  }

  @override
  String get clearDates => 'Vymazat data';

  @override
  String get reminderNotification => 'Oznámení s připomenutím';

  @override
  String get reminderNotificationSub => 'Poslat oznámení ve dny plánu';

  @override
  String notifyAt(String time) {
    return 'Připomenout v  $time';
  }

  @override
  String get customMessageHint =>
      'Vlastní zpráva (nepovinné)\nnapř. Čas vyrazit ven!';

  @override
  String get leaveEmptyDefault => 'Nechte prázdné pro výchozí zprávu.';

  @override
  String get timeAlreadyPassed =>
      'Tento čas už uplynul, takže oznámení nepřijde. Vyberte pozdější čas.';

  @override
  String get alsoAddTo => 'Přidat také do (nepovinné)';

  @override
  String get calendar => 'Kalendář';

  @override
  String get remindersApp => 'Připomínky';

  @override
  String get alsoAddToHint =>
      'Při uložení: otevře se Kalendář s vyplněným plánem, abyste mohli pozvat ostatní. Připomínky dostanou plán s upozorněním v jeho čase.';

  @override
  String get inactivePlansHidden =>
      'Neaktivní plány se v sekci Dnes nezobrazují';

  @override
  String get themeModernistLight => 'Modernist – světlý';

  @override
  String get themeModernistLightSub => 'Červená a černá na papíře, originál';

  @override
  String get themeModernistDark => 'Modernist – tmavý';

  @override
  String get themeModernistDarkSub => 'Korálová na teplé černé';

  @override
  String get themeSwingLight => 'Swing – světlý';

  @override
  String get themeSwingLightSub => 'Tmavě zelená a oranžová na slunečně žluté';

  @override
  String get themeSwingDark => 'Swing – tmavý';

  @override
  String get themeSwingDarkSub => 'Slunečně žlutá na tmavě zelené';

  @override
  String get themeBlackOnWhite => 'Černá na bílé';

  @override
  String get themeBlackOnWhiteSub => 'Prostá černá na bílé';

  @override
  String get themeWhiteOnBlack => 'Bílá na černé';

  @override
  String get themeWhiteOnBlackSub => 'Prostá bílá na černé';

  @override
  String get themeMyColors => 'Moje barvy';

  @override
  String get themeMyColorsSub => 'Vlastní pozadí, text a zvýraznění';

  @override
  String get family => 'Rodina';

  @override
  String get parentsAndKids => 'Rodiče a děti';

  @override
  String get familySync => 'Rodinná synchronizace';

  @override
  String get familySyncSub => 'Sdílení mezi Apple ID';

  @override
  String get app => 'Aplikace';

  @override
  String get remindersSetting => 'Připomenutí';

  @override
  String get languageDateTheme => 'Jazyk, datum a motiv';

  @override
  String get privacy => 'Soukromí';

  @override
  String get noDataCollected => 'Žádná data se nesbírají';

  @override
  String get yourData => 'Vaše data';

  @override
  String get logSub => 'Všechny návštěvy, nejnovější nahoře';

  @override
  String get deleteAllData => 'Smazat všechna data';

  @override
  String get deleteAllDataSub => 'V tomto iPhonu a na iCloudu';

  @override
  String get aboutNote =>
      'Playground Tracker se v App Storu kupuje jednou. Žádné předplatné, žádný účet, žádné reklamy. Vaše záznamy zůstávají ve vašich zařízeních a synchronizují se přes váš vlastní iCloud.';

  @override
  String get deleteAllDataQuestion => 'Smazat všechna data?';

  @override
  String get deleteAllDataBody =>
      'Každá návštěva, plán, jméno i nastavení se smaže z tohoto iPhonu a z vašeho iCloudu. Pokud záznamy sdílíte s rodinou, přijdou o ně i oni. Tuto akci nelze vrátit.';

  @override
  String get deleteEverything => 'Smazat vše';

  @override
  String get deleting => 'Mazání…';

  @override
  String get nothingDeleted => 'Nic nebylo smazáno';

  @override
  String get nothingDeletedBody =>
      'iCloud nebyl dostupný, takže vaše data zůstala, jak byla (jinak by je synchronizace vrátila). Zkuste to znovu, až budete online.';

  @override
  String get ok => 'OK';

  @override
  String get notificationsTitle => 'Připomenutí';

  @override
  String get outdoorReminder => 'Připomenutí na ven';

  @override
  String get outdoorReminderSub =>
      'Byli jste dnes s dětmi venku? Přijde jednou denně ve zvolený čas.';

  @override
  String get logReminder => 'Připomenutí zápisu';

  @override
  String get logReminderSub =>
      'Nezapomeňte zapsat dnešní návštěvu hřiště. Přijde jednou denně ve zvolený čas.';

  @override
  String everyDayAt(String time) {
    return 'Každý den v  $time';
  }

  @override
  String get notificationsBlocked =>
      'Oznámení jsou blokovaná. Otevřete Nastavení › Playground Tracker › Oznámení a povolte je.';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get notificationsLocalNote =>
      'Oznámení jsou místní, internet není potřeba. Každý v rodině si nastavuje vlastní časy ve vlastním telefonu.';

  @override
  String get language => 'Jazyk';

  @override
  String get phoneLanguage => 'Jazyk telefonu';

  @override
  String get colorTheme => 'Barevný motiv';

  @override
  String get editMyColors => 'Upravit moje barvy';

  @override
  String get timeFormat => 'Formát času';

  @override
  String get hour12 => '12hodinový';

  @override
  String get hour24 => '24hodinový';

  @override
  String get changesApplyImmediately => 'Změny platí okamžitě v celé aplikaci.';

  @override
  String contrastTextWarning(String ratio) {
    return 'Text je na tomto pozadí špatně čitelný: kontrast $ratio:1, ideálně 4,5:1 nebo víc.';
  }

  @override
  String contrastAccentWarning(String ratio) {
    return 'Zvýraznění je na tomto pozadí špatně vidět: kontrast $ratio:1, ideálně 3:1 nebo víc.';
  }

  @override
  String get sampleMom => 'Máma';

  @override
  String get sampleDad => 'Táta';

  @override
  String get colorBackground => 'Pozadí';

  @override
  String get colorText => 'Text';

  @override
  String get colorAccent => 'Zvýraznění (tlačítka, výběr)';

  @override
  String get notifOutdoorTitle => 'Připomenutí hřiště';

  @override
  String get notifOutdoorBody => 'Byli jste dnes s dětmi venku?';

  @override
  String get notifLogTitle => 'Zapište čas venku';

  @override
  String get notifLogBody => 'Nezapomeňte zapsat dnešní návštěvu hřiště.';

  @override
  String get notifPlanDefaultBody => 'Je čas na váš plán';

  @override
  String get addParentAndKid => 'Přidejte alespoň jednoho rodiče a jedno dítě';

  @override
  String get welcome => 'Vítejte';

  @override
  String get familyEditIntro =>
      'Upravte členy rodiny. Stávající záznamy se nezmění.';

  @override
  String get familySetupIntro =>
      'Nastavíme vaši rodinu. Další lidi můžete kdykoli přidat později.';

  @override
  String get parentsGrandparents => 'Rodiče / prarodiče';

  @override
  String get parentHint1 => 'např. Máma';

  @override
  String get parentHint2 => 'např. Táta';

  @override
  String get parentHintMore => 'Rodič nebo prarodič';

  @override
  String get addParent => '+ Přidat dospělého';

  @override
  String get kidHint1 => 'např. Ema';

  @override
  String get kidHint2 => 'např. Tomáš';

  @override
  String get kidHintMore => 'Jméno dítěte';

  @override
  String get addKid => '+ Přidat dítě';

  @override
  String get saveChanges => 'Uložit změny';

  @override
  String get saveAndStart => 'Uložit a začít';

  @override
  String minutesAgo(int count) {
    return 'před $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'před $count h';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'před $count dny',
      few: 'před $count dny',
      one: 'před 1 dnem',
    );
    return '$_temp0';
  }

  @override
  String get removeAccessQuestion => 'Odebrat přístup?';

  @override
  String removeAccessBody(String name) {
    return '$name se už nebude synchronizovat s těmito záznamy. Stávající záznamy zůstanou v jeho/jejím telefonu.';
  }

  @override
  String get remove => 'Odebrat';

  @override
  String get couldNotRemove => 'Odebrání se nepovedlo. Zkuste to znovu.';

  @override
  String get connectedUser => 'Připojená osoba';

  @override
  String get inviteSomeone => 'Pozvat někoho';

  @override
  String get inviteSub =>
      'Otevře nabídku sdílení iOS: pošlete přes Zprávy, WhatsApp nebo zkopírujte odkaz';

  @override
  String get connected => 'Připojeno';

  @override
  String lastSynced(String time) {
    return 'Naposledy synchronizováno $time';
  }

  @override
  String get shareWithFamily => 'Sdílejte s rodinou';

  @override
  String get shareWithFamilySub =>
      'Každý používá své vlastní Apple ID. Společné účty nejsou potřeba.';

  @override
  String get owner => 'Vlastník';

  @override
  String get invitePending => 'Pozvánka čeká…';

  @override
  String get you => 'Vy';

  @override
  String get noOneConnected => 'Zatím nikdo není připojený';

  @override
  String get noOneConnectedHint =>
      'Klepnutím na „Pozvat někoho“ nahoře sdílejte\ns partnerem nebo rodinou.';

  @override
  String get howItWorks => 'Jak to funguje';

  @override
  String get howStep1 =>
      'Klepněte na „Pozvat někoho“ a otevře se nabídka sdílení iOS';

  @override
  String get howStep2 =>
      'Pošlete odkaz přes Zprávy, WhatsApp nebo ho zkopírujte';

  @override
  String get howStep3 =>
      'Druhá osoba klepne na odkaz a pak na „Přijmout“. Hotovo.';

  @override
  String get howStep4 => 'Oba telefony se synchronizují samy';

  @override
  String get onbParentsTitle => 'Kdo chodí s dětmi ven?';

  @override
  String get onbParentsNote =>
      'Skutečná jména nejsou potřeba: Máma a Táta, přezdívky nebo iniciály poslouží stejně dobře. Jména se zobrazují jen v aplikaci.';

  @override
  String get onbKidsTitle => 'A děti?';

  @override
  String get onbKidHint1 => 'např. Fazolka';

  @override
  String get onbKidHint2 => 'např. Tygr';

  @override
  String get onbKidsNote =>
      'I tady jsou přezdívky ideální. Vše zůstává ve vašem iPhonu a ve vašem vlastním iCloudu, nikdy u nás.';

  @override
  String get getStarted => 'Začít';

  @override
  String get startUsingApp => 'Začít používat aplikaci';

  @override
  String get skipForNow => 'Zatím přeskočit';

  @override
  String get continueLabel => 'Pokračovat';

  @override
  String get back => 'Zpět';

  @override
  String get onbWelcome1 =>
      'Rychlý záznam času, který vaše rodina tráví venku: kdo vzal děti ven, na jak dlouho a co dělaly.';

  @override
  String get onbWelcome2 =>
      'V dalších krocích nastavíte rodinu, nepovinná připomenutí a plány. Zabere to asi minutu a vše můžete později změnit v Nastavení.';

  @override
  String get onbWelcomeNote =>
      'Žádný účet, žádné reklamy, žádné sledování. Vaše záznamy zůstávají ve vašem iPhonu a ve vašem vlastním iCloudu.';

  @override
  String get name => 'Jméno';

  @override
  String get addAnotherChip => '+ Přidat další';

  @override
  String get onbRemindersIntro =>
      'Nepovinné. Jemné připomenutí jednou denně ve zvolený čas. iOS požádá o povolení, až nějaké zapnete.';

  @override
  String get onbReminderOutside => 'Čas jít ven';

  @override
  String get onbReminderLog => 'Zapsat dnešní návštěvu';

  @override
  String get onbRemindersLater =>
      'Kdykoli to můžete změnit v Nastavení › Připomenutí.';

  @override
  String everyDayAtChange(String time) {
    return 'Každý den v $time · změnit';
  }

  @override
  String get onbPlansIntro =>
      'Nepovinné. Fotbal každé pondělí, plavání v sobotu, narozeninová oslava příští týden: plány se zobrazí v sekci Dnes, připravené k odškrtnutí, a umí vám připomenout.';

  @override
  String get addAPlan => 'Přidat plán';

  @override
  String get addAnotherPlan => 'Přidat další plán';

  @override
  String get onbPlansLater =>
      'Další plány můžete kdykoli přidat na kartě Plány.';

  @override
  String get onbLookTitle => 'Váš vzhled';

  @override
  String get onbLookIntro =>
      'Vyberte barevný motiv nebo si vytvořte vlastní. Kdykoli ho můžete změnit v Nastavení.';

  @override
  String get privInShortTitle => 'Stručně';

  @override
  String get privInShort =>
      'Playground Tracker nesbírá osobní údaje. Neexistuje žádný účet, žádný náš server, žádná analytika, reklama ani sledování. Vývojář vaše záznamy nevidí.';

  @override
  String get privStoresTitle => 'Co aplikace ukládá';

  @override
  String get privStores =>
      'Jména rodičů a dětí, která zadáte, vaše návštěvy (datum, dopoledne nebo odpoledne, kdo šel, které děti, jak dlouho, aktivity a jakýkoli důvod, který uvedete), vaše plány a jak dopadly, a vaše nastavení. Vše je uloženo v soukromém úložišti aplikace ve vašem iPhonu.';

  @override
  String get privICloudTitle => 'Synchronizace přes iCloud a sdílení s rodinou';

  @override
  String get privICloud =>
      'Pokud jste přihlášeni k iCloudu, aplikace uchovává kopii ve vaší vlastní soukromé databázi iCloud prostřednictvím Apple CloudKit, aby vše zůstalo synchronizované mezi vašimi zařízeními. Pokud pozvete členy rodiny odkazem, pozvaní mohou sdílené záznamy vidět a upravovat, dokud sdílení neukončíte. Data na iCloudu spravuje Apple podle svých zásad ochrany soukromí; vývojář k nim nemá přístup.';

  @override
  String get privRemindersTitle => 'Připomenutí';

  @override
  String get privReminders =>
      'Oznámení s připomenutím se plánují ve vašem iPhonu. Nic o nich se nikam neodesílá. Aplikace žádá o povolení, až když připomenutí zapnete.';

  @override
  String get privCalendarTitle => 'Kalendář a Připomínky';

  @override
  String get privCalendar =>
      '„Přidat do Kalendáře“ otevře vlastní editor událostí od Applu s vyplněným plánem. Aplikace váš kalendář nečte; událost se uloží, jen pokud klepnete na Přidat. „Přidat do Připomínek“ uloží plán jako jednu novou připomínku ve vaší aplikaci Připomínky. Aplikace vaše připomínky nečte a nic se nikam neodesílá.';

  @override
  String get privChildrenTitle => 'Děti';

  @override
  String get privChildren =>
      'Aplikace je určena rodičům. Jména dětí zůstávají ve vašem iPhonu a ve vašem vlastním iCloudu. Nic o dětech se neodesílá vývojáři ani nikomu jinému.';

  @override
  String get privDeletingTitle => 'Smazání vašich dat';

  @override
  String get privDeleting =>
      'Nastavení › Smazat všechna data odstraní vše najednou, z vašeho iPhonu i z vašeho iCloudu; pokud záznamy sdílíte s rodinou, odstraní se i jim. Jednotlivé záznamy můžete smazat kdykoli a smazáním aplikace se odstraní vše uložené v iPhonu. Sdílení ukončíte v Nastavení › Rodinná synchronizace.';

  @override
  String get privChangesTitle => 'Změny';

  @override
  String get privChanges =>
      'Pokud se tyto zásady změní, nová verze přijde s aktualizací aplikace a datum nahoře se změní.';

  @override
  String privacyEffective(String date) {
    return 'Platné od $date';
  }

  @override
  String get dashTapToChange => '— klepnutím změníte';

  @override
  String get hour24Time => '24hodinový formát';

  @override
  String get justNow => 'právě teď';

  @override
  String parentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dospělých',
      few: '$count dospělí',
      one: '$count dospělý',
    );
    return '$_temp0';
  }

  @override
  String kidsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dětí',
      few: '$count děti',
      one: '$count dítě',
    );
    return '$_temp0';
  }

  @override
  String personRemoved(String name) {
    return '$name odebrán/a';
  }

  @override
  String get advanced => 'Pokročilé';

  @override
  String get startTime => 'Začátek';

  @override
  String get endTime => 'Konec';

  @override
  String get endAfterStart => 'Konec musí být po začátku';

  @override
  String timeOutside(String time) {
    return '$time venku';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dní v řadě',
      few: 'dny v řadě',
      one: 'den v řadě',
    );
    return '$_temp0';
  }

  @override
  String get streakDoneToday => 'Pro dnešek splněno';

  @override
  String get streakKeepGoing => 'Vyrazte dnes ven, ať série pokračuje';

  @override
  String get streakAtRisk =>
      'Včera vynecháno. Vyrazte dnes ven, jinak série skončí';

  @override
  String get streakStart => 'Vyrazte dnes ven a začněte sérii';

  @override
  String get streakRule =>
      'Série počítá dny, kdy jste byli venku. Jeden vynechaný den se odpouští, dva po sobě ji ukončí. Dovolená ji pozastaví.';

  @override
  String get goal => 'Cíl';

  @override
  String get setAGoal => 'Nastavte si cíl pro čas venku';

  @override
  String goalOf(String done, String target) {
    return '$done z $target';
  }

  @override
  String get goalReached => 'Cíl splněn';

  @override
  String get goalOnTrack => 'Podle plánu';

  @override
  String goalBehind(String time) {
    return '$time pozadu';
  }

  @override
  String get outdoorGoal => 'Cíl času venku';

  @override
  String get goalPeriod => 'Období';

  @override
  String get hoursOutside => 'Hodin venku';

  @override
  String get otherAmount => 'Jiné';

  @override
  String get hoursHint => 'Hodiny, např. 12';

  @override
  String get goalNote =>
      'Počítá délku každé zapsané návštěvy. Oblíbený cíl je 1000 hodin ročně: asi 2 hodiny 45 minut denně.';

  @override
  String get turnOffGoal => 'Vypnout cíl';

  @override
  String get goalOff => 'Vypnuto';

  @override
  String goalAWeek(String time) {
    return '$time týdně';
  }

  @override
  String goalAMonth(String time) {
    return '$time měsíčně';
  }

  @override
  String goalAYear(String time) {
    return '$time ročně';
  }

  @override
  String get outdoorActivity => 'Aktivita venku';

  @override
  String get outdoorActivitySub =>
      'Splněno se počítá jako čas venku. Vypněte u věcí jako hodiny klavíru.';

  @override
  String goalSince(String date) {
    return 'Od $date';
  }
}
