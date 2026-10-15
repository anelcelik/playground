// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get reasonRain => 'Kiša';

  @override
  String get reasonSick => 'Bolest';

  @override
  String get reasonTooLate => 'Prekasno';

  @override
  String get reasonBusy => 'Nema vremena';

  @override
  String get reasonCancelled => 'Otkazano';

  @override
  String get reasonOther => 'Ostalo';

  @override
  String get today => 'Danas';

  @override
  String get history => 'Historija';

  @override
  String get plans => 'Planovi';

  @override
  String get settings => 'Postavke';

  @override
  String get visitLogged => 'Posjeta upisana';

  @override
  String get edit => 'Uredi';

  @override
  String get recap => 'Pregled';

  @override
  String get yesterday => 'Jučer';

  @override
  String get addAnother => 'Dodaj još jednu';

  @override
  String get logAVisit => 'Upiši posjetu';

  @override
  String get sameAsUsual => 'Kao obično';

  @override
  String get morning => 'Prijepodne';

  @override
  String get evening => 'Popodne';

  @override
  String get nobodyWentToday => 'Danas niko nije išao';

  @override
  String get nobodyWent => 'Niko nije išao';

  @override
  String get onVacation => 'Na odmoru';

  @override
  String get notLogged => 'Nije upisano';

  @override
  String reasonTapToChange(String reason) {
    return '$reason · dodirni za promjenu';
  }

  @override
  String get tapToChange => 'Dodirni za promjenu';

  @override
  String get plannedForToday => 'Plan za danas';

  @override
  String get planned => 'Planirano';

  @override
  String doneOfTotal(int done, int total) {
    return '$done od $total urađeno';
  }

  @override
  String get confirmedTapToEdit => 'Potvrđeno · dodirni za uređivanje';

  @override
  String skippedBecause(String reason) {
    return 'Preskočeno · $reason';
  }

  @override
  String get skipped => 'Preskočeno';

  @override
  String get missed => 'Propušteno';

  @override
  String get done => 'Urađeno';

  @override
  String get skip => 'Preskoči';

  @override
  String get whySkip => 'Zašto preskačeš?';

  @override
  String whySkipHint(String title) {
    return 'Odaberi ili napiši zašto „$title“ nije bilo.';
  }

  @override
  String get addActivity => 'Dodaj aktivnost';

  @override
  String get addActivityHint => 'npr. Pješčanik';

  @override
  String get cancel => 'Odustani';

  @override
  String get add => 'Dodaj';

  @override
  String get morningVisit => 'Prijepodnevna posjeta';

  @override
  String get eveningVisit => 'Popodnevna posjeta';

  @override
  String get save => 'Sačuvaj';

  @override
  String get whoWent => 'Ko je išao';

  @override
  String whyDidntGo(String names) {
    return 'Zašto $names nije išao/išla?  ·  neobavezno';
  }

  @override
  String get kids => 'Djeca';

  @override
  String get howLong => 'Koliko dugo';

  @override
  String get activitiesOptional => 'Aktivnosti  ·  neobavezno';

  @override
  String get addChip => '+ Dodaj';

  @override
  String get onlyWhoWentRequired => 'Obavezno je samo „ko je išao“.';

  @override
  String get prefilledMorning =>
      'Popunjeno prema tvojoj posljednjoj prijepodnevnoj posjeti.';

  @override
  String get prefilledEvening =>
      'Popunjeno prema tvojoj posljednjoj popodnevnoj posjeti.';

  @override
  String get updateVisit => 'Ažuriraj posjetu';

  @override
  String get saveVisit => 'Sačuvaj posjetu';

  @override
  String get whyNot => 'Zašto ne?';

  @override
  String get whyNotHint =>
      'Odaberi ili napiši razlog da sačuvaš dan kao „niko nije išao“.';

  @override
  String get writeYourOwn => '+ Napiši svoj';

  @override
  String get typeReasonHint => 'npr. Nana u posjeti';

  @override
  String get editEntry => 'Uredi unos';

  @override
  String get changeReason => 'Promijeni razlog';

  @override
  String get deleteEntry => 'Obriši unos';

  @override
  String get deleteEntryQuestion => 'Obrisati unos?';

  @override
  String deleteEntryBody(String date) {
    return '$date: briše se i na sinhronizovanim uređajima.';
  }

  @override
  String get delete => 'Obriši';

  @override
  String get entryDeleted => 'Unos obrisan';

  @override
  String get undo => 'Poništi';

  @override
  String get vacation => 'Odmor';

  @override
  String absentDidntGo(String names, String reasons) {
    return '$names nije išao/išla · $reasons';
  }

  @override
  String get selectWhoWent => 'Odaberi ko je išao';

  @override
  String get editEntryTitle => 'Uredi unos';

  @override
  String get whoWentQ => 'Ko je išao?';

  @override
  String get whenQ => 'Kada?';

  @override
  String get howLongQ => 'Koliko dugo?';

  @override
  String get whichKidsQ => 'Koja djeca?';

  @override
  String get activities => 'Aktivnosti';

  @override
  String get addActivityEllipsis => 'Dodaj aktivnost…';

  @override
  String get log => 'Dnevnik';

  @override
  String get logEmpty =>
      'Još ništa nije upisano. Posjete koje upišeš pod Danas pojavljuju se ovdje, najnovije prve.';

  @override
  String get thisMonth => 'Ovaj mjesec';

  @override
  String get thisYear => 'Ova godina';

  @override
  String playgroundVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'posjeta igralištu',
      few: 'posjete igralištu',
      one: 'posjeta igralištu',
    );
    return '$_temp0';
  }

  @override
  String outsideAsFamily(String time) {
    return '$time napolju kao porodica';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dana',
      few: '$count dana',
      one: '$count dan',
    );
    return '$_temp0';
  }

  @override
  String get longestStreak => 'Najduži niz';

  @override
  String get topActivity => 'Omiljena aktivnost';

  @override
  String get wentTheMost => 'Najčešće išao/išla';

  @override
  String kidOutsideMost(String name) {
    return '$name je najviše bio/bila napolju';
  }

  @override
  String get taglineLots => 'To je puno svježeg zraka. Bravo!';

  @override
  String taglineSolid(String period) {
    return '$period: dosta svježeg zraka. Samo tako nastavi!';
  }

  @override
  String get taglineEvery => 'Svaka posjeta se računa. Neka ih bude još više.';

  @override
  String recapEmpty(String period) {
    return 'Još ništa nije upisano za $period';
  }

  @override
  String get recapEmptyHint => 'Upiši posjetu i pojavit će se ovdje.';

  @override
  String get allTime => 'Sve ukupno';

  @override
  String get customiseDashboard => 'Prilagodi historiju';

  @override
  String get week => 'Sedmica';

  @override
  String get month => 'Mjesec';

  @override
  String get year => 'Godina';

  @override
  String get all => 'Sve';

  @override
  String get whoTookThem => 'Ko ih je vodio';

  @override
  String get nobodyLoggedYet => 'Još niko nije upisan';

  @override
  String get kidsOutside => 'Djeca napolju';

  @override
  String get noKidsLoggedYet => 'Još nema upisane djece';

  @override
  String get morningEvening => 'Prijepodne / popodne';

  @override
  String get noVisitsThisPeriod => 'Nema posjeta u ovom periodu';

  @override
  String visitsInPeriod(String period) {
    return 'Posjete · $period';
  }

  @override
  String get outside => 'Napolju';

  @override
  String get thisWeek => 'Ova sedmica';

  @override
  String get oneSquarePerDayLower => 'jedan kvadrat po danu';

  @override
  String get oneSquarePerMonthLower => 'jedan kvadrat po mjesecu';

  @override
  String get legendBusy => 'Puno';

  @override
  String get legendBoth => 'Oboje';

  @override
  String get legendSome => 'Malo';

  @override
  String get legendOne => 'Jedan';

  @override
  String get legendNone => 'Niko';

  @override
  String get mostPlayed => 'Najviše igrano';

  @override
  String get noActivitiesLoggedYet => 'Još nema upisanih aktivnosti';

  @override
  String get timeAndMissedDays => 'Vrijeme i propušteni dani';

  @override
  String get averageVisit => 'Prosječna posjeta';

  @override
  String get whyNobodyWent => 'Zašto niko nije išao';

  @override
  String get noMissedDays => 'Nema propuštenih dana u ovom periodu';

  @override
  String get noReasonsLoggedYet => 'Još nema upisanih razloga';

  @override
  String get customiseDashboardTitle => 'Prilagodi historiju';

  @override
  String get reset => 'Vrati na početno';

  @override
  String get dragToReorder =>
      'Povuci za redoslijed  ·  prekidač za prikaz ili skrivanje';

  @override
  String get oneSquarePerDay => 'Jedan kvadrat po danu';

  @override
  String onceOn(String date) {
    return 'Jednom · $date';
  }

  @override
  String get noDays => 'Bez dana';

  @override
  String get everyDay => 'Svaki dan';

  @override
  String get weekdays => 'Radnim danima';

  @override
  String get weekends => 'Vikendom';

  @override
  String get addedToReminders => 'Dodano u Podsjetnike';

  @override
  String get addedToCalendar => 'Dodano u kalendar';

  @override
  String get remindersDenied =>
      'Pristup Podsjetnicima je isključen. Dozvoli ga u postavkama iPhonea.';

  @override
  String get calendarDenied =>
      'Pristup Kalendaru je isključen. Dozvoli ga u postavkama iPhonea.';

  @override
  String get planNoUpcomingDay =>
      'Ovaj plan nema nijedan nadolazeći dan za dodavanje';

  @override
  String get remindersUnavailable => 'Podsjetnici postoje samo na iPhoneu';

  @override
  String get calendarUnavailable => 'Kalendar postoji samo na iPhoneu';

  @override
  String get remindersError => 'Dodavanje u Podsjetnike nije uspjelo';

  @override
  String get calendarError => 'Dodavanje u Kalendar nije uspjelo';

  @override
  String withKids(String names) {
    return 'Sa: $names';
  }

  @override
  String get editPlan => 'Uredi plan';

  @override
  String get addToCalendar => 'Dodaj u Kalendar';

  @override
  String get addToCalendarSub =>
      'Otvara Kalendar na iPhoneu: tamo pozovi druge';

  @override
  String get addToReminders => 'Dodaj u Podsjetnike';

  @override
  String get addToRemindersSub => 'Podsjetnik sa upozorenjem u vrijeme plana';

  @override
  String get todayNotDoneYet => 'Danas · još nije urađeno';

  @override
  String get planNoDaysYet =>
      'Još nema dana. Pojavit će se ovdje kad plan počne.';

  @override
  String get deletePlanQuestion => 'Obrisati plan?';

  @override
  String deletePlanBody(String title) {
    return '„$title“ i cijela njegova historija bit će trajno obrisani.';
  }

  @override
  String get newPlan => 'Novi plan';

  @override
  String get active => 'Aktivan';

  @override
  String get inactive => 'Neaktivan';

  @override
  String reminderAt(String time) {
    return 'Podsjetnik $time';
  }

  @override
  String get tapForHistory => 'Dodirni za historiju, Kalendar i Podsjetnike';

  @override
  String get deactivate => 'Deaktiviraj';

  @override
  String get activate => 'Aktiviraj';

  @override
  String get noPlansYet => 'Još nema planova';

  @override
  String get noPlansHint =>
      'Dodaj planove koji se ponavljaju određenim danima ili se dese jednom.\nPojavljuju se pod Danas.';

  @override
  String get addFirstPlan => 'Dodaj prvi plan';

  @override
  String get enterTitle => 'Upiši naziv';

  @override
  String get pickADate => 'Odaberi datum';

  @override
  String get selectAtLeastOneDay => 'Odaberi barem jedan dan';

  @override
  String get notSet => 'Nije postavljeno';

  @override
  String get planTitle => 'Naziv';

  @override
  String get planTitleHint => 'npr. Fudbal';

  @override
  String get howOftenQ => 'Koliko često?';

  @override
  String get repeats => 'Ponavlja se';

  @override
  String get oneTime => 'Jednom';

  @override
  String dateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get repeatOn => 'Ponavljaj';

  @override
  String get dateRangeOptional => 'Period (neobavezno)';

  @override
  String fromDate(String date) {
    return 'Od: $date';
  }

  @override
  String toDate(String date) {
    return 'Do: $date';
  }

  @override
  String get clearDates => 'Obriši datume';

  @override
  String get reminderNotification => 'Obavijest za podsjetnik';

  @override
  String get reminderNotificationSub => 'Pošalji obavijest u dane plana';

  @override
  String notifyAt(String time) {
    return 'Podsjeti u  $time';
  }

  @override
  String get customMessageHint =>
      'Vlastita poruka (neobavezno)\nnpr. Vrijeme je za izlazak!';

  @override
  String get leaveEmptyDefault => 'Ostavi prazno za standardnu poruku.';

  @override
  String get timeAlreadyPassed =>
      'Ovo vrijeme je već prošlo, pa obavijest neće stići. Odaberi kasnije vrijeme.';

  @override
  String get alsoAddTo => 'Dodaj i u (neobavezno)';

  @override
  String get calendar => 'Kalendar';

  @override
  String get remindersApp => 'Podsjetnici';

  @override
  String get alsoAddToHint =>
      'Kad sačuvaš: Kalendar se otvara sa već popunjenim planom, pa možeš pozvati druge. Podsjetnici dobijaju plan sa upozorenjem u njegovo vrijeme.';

  @override
  String get inactivePlansHidden =>
      'Neaktivni planovi se ne prikazuju pod Danas';

  @override
  String get themeModernistLight => 'Modernist – svijetla';

  @override
  String get themeModernistLightSub => 'Crvena i crna na papiru, original';

  @override
  String get themeModernistDark => 'Modernist – tamna';

  @override
  String get themeModernistDarkSub => 'Koraljna na toploj crnoj';

  @override
  String get themeSwingLight => 'Swing – svijetla';

  @override
  String get themeSwingLightSub => 'Tamnozelena i narandžasta na sunčano žutoj';

  @override
  String get themeSwingDark => 'Swing – tamna';

  @override
  String get themeSwingDarkSub => 'Sunčano žuta na tamnozelenoj';

  @override
  String get themeBlackOnWhite => 'Crno na bijelom';

  @override
  String get themeBlackOnWhiteSub => 'Jednostavno crno na bijelom';

  @override
  String get themeWhiteOnBlack => 'Bijelo na crnom';

  @override
  String get themeWhiteOnBlackSub => 'Jednostavno bijelo na crnom';

  @override
  String get themeMyColors => 'Moje boje';

  @override
  String get themeMyColorsSub => 'Tvoja pozadina, tekst i akcent';

  @override
  String get family => 'Porodica';

  @override
  String get parentsAndKids => 'Roditelji i djeca';

  @override
  String get familySync => 'Porodična sinhronizacija';

  @override
  String get familySyncSub => 'Dijeli između Apple ID-ova';

  @override
  String get app => 'Aplikacija';

  @override
  String get remindersSetting => 'Podsjetnici';

  @override
  String get languageDateTheme => 'Jezik, datum i tema';

  @override
  String get privacy => 'Privatnost';

  @override
  String get noDataCollected => 'Ne prikupljaju se podaci';

  @override
  String get yourData => 'Tvoji podaci';

  @override
  String get logSub => 'Sve posjete, najnovije prve';

  @override
  String get deleteAllData => 'Obriši sve podatke';

  @override
  String get deleteAllDataSub => 'Na ovom iPhoneu i u iCloudu';

  @override
  String get aboutNote =>
      'Playground Tracker se kupuje jednom u App Storeu. Bez pretplate, bez računa, bez reklama. Tvoj dnevnik ostaje na tvojim uređajima i sinhronizuje se kroz tvoj vlastiti iCloud.';

  @override
  String get deleteAllDataQuestion => 'Obrisati sve podatke?';

  @override
  String get deleteAllDataBody =>
      'Svaka posjeta, plan, ime i postavka briše se sa ovog iPhonea i iz tvog iClouda. Ako dnevnik dijeliš sa porodicom, i oni ga gube. Ovo se ne može poništiti.';

  @override
  String get deleteEverything => 'Obriši sve';

  @override
  String get deleting => 'Brisanje…';

  @override
  String get nothingDeleted => 'Ništa nije obrisano';

  @override
  String get nothingDeletedBody =>
      'iCloud nije bio dostupan, pa su tvoji podaci ostali kakvi jesu (inače bi ih sinhronizacija vratila). Pokušaj ponovo kad budeš online.';

  @override
  String get ok => 'U redu';

  @override
  String get notificationsTitle => 'Podsjetnici';

  @override
  String get outdoorReminder => 'Podsjetnik za izlazak';

  @override
  String get outdoorReminderSub =>
      'Jesi li danas izveo/izvela djecu napolje? Stiže jednom dnevno, u vrijeme koje odabereš.';

  @override
  String get logReminder => 'Podsjetnik za upis';

  @override
  String get logReminderSub =>
      'Ne zaboravi upisati današnju posjetu igralištu. Stiže jednom dnevno, u vrijeme koje odabereš.';

  @override
  String everyDayAt(String time) {
    return 'Svaki dan u  $time';
  }

  @override
  String get notificationsBlocked =>
      'Obavijesti su blokirane. Otvori Postavke › Playground Tracker › Obavijesti i dozvoli ih.';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get notificationsLocalNote =>
      'Obavijesti su lokalne, internet nije potreban. Svako u porodici postavlja svoja vremena na svom telefonu.';

  @override
  String get language => 'Jezik';

  @override
  String get phoneLanguage => 'Jezik telefona';

  @override
  String get colorTheme => 'Tema boja';

  @override
  String get editMyColors => 'Uredi moje boje';

  @override
  String get timeFormat => 'Format vremena';

  @override
  String get hour12 => '12 sati';

  @override
  String get hour24 => '24 sata';

  @override
  String get changesApplyImmediately =>
      'Promjene odmah važe u cijeloj aplikaciji.';

  @override
  String contrastTextWarning(String ratio) {
    return 'Tekst se teško čita na ovoj pozadini: kontrast $ratio:1, cilj je 4,5:1 ili više.';
  }

  @override
  String contrastAccentWarning(String ratio) {
    return 'Akcent se teško vidi na ovoj pozadini: kontrast $ratio:1, cilj je 3:1 ili više.';
  }

  @override
  String get sampleMom => 'Mama';

  @override
  String get sampleDad => 'Tata';

  @override
  String get colorBackground => 'Pozadina';

  @override
  String get colorText => 'Tekst';

  @override
  String get colorAccent => 'Akcent (dugmad, odabir)';

  @override
  String get notifOutdoorTitle => 'Podsjetnik za igralište';

  @override
  String get notifOutdoorBody => 'Jesi li danas izveo/izvela djecu napolje?';

  @override
  String get notifLogTitle => 'Upiši vrijeme napolju';

  @override
  String get notifLogBody => 'Ne zaboravi upisati današnju posjetu igralištu.';

  @override
  String get notifPlanDefaultBody => 'Vrijeme je za tvoj plan';

  @override
  String get addParentAndKid => 'Dodaj barem jednog roditelja i jedno dijete';

  @override
  String get welcome => 'Dobro došli';

  @override
  String get familyEditIntro =>
      'Ažuriraj članove porodice. Postojeći unosi se ne mijenjaju.';

  @override
  String get familySetupIntro =>
      'Hajde da postavimo tvoju porodicu. Uvijek možeš kasnije dodati još ljudi.';

  @override
  String get parentsGrandparents => 'Roditelji / nana i dedo';

  @override
  String get parentHint1 => 'npr. Mama';

  @override
  String get parentHint2 => 'npr. Tata';

  @override
  String get parentHintMore => 'Roditelj, nana ili dedo';

  @override
  String get addParent => '+ Dodaj odraslu osobu';

  @override
  String get kidHint1 => 'npr. Lejla';

  @override
  String get kidHint2 => 'npr. Amar';

  @override
  String get kidHintMore => 'Ime djeteta';

  @override
  String get addKid => '+ Dodaj dijete';

  @override
  String get saveChanges => 'Sačuvaj promjene';

  @override
  String get saveAndStart => 'Sačuvaj i počni';

  @override
  String minutesAgo(int count) {
    return 'prije $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'prije $count h';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'prije $count dana',
      few: 'prije $count dana',
      one: 'prije $count dan',
    );
    return '$_temp0';
  }

  @override
  String get removeAccessQuestion => 'Ukloniti pristup?';

  @override
  String removeAccessBody(String name) {
    return '$name se više neće sinhronizovati sa ovim dnevnikom. Postojeći unosi ostaju na njihovom telefonu.';
  }

  @override
  String get remove => 'Ukloni';

  @override
  String get couldNotRemove => 'Uklanjanje nije uspjelo. Pokušaj ponovo.';

  @override
  String get connectedUser => 'Povezana osoba';

  @override
  String get inviteSomeone => 'Pozovi nekoga';

  @override
  String get inviteSub =>
      'Otvara iOS meni za dijeljenje: pošalji kroz Poruke, WhatsApp ili kopiraj link';

  @override
  String get connected => 'Povezano';

  @override
  String lastSynced(String time) {
    return 'Posljednja sinhronizacija $time';
  }

  @override
  String get shareWithFamily => 'Dijeli sa porodicom';

  @override
  String get shareWithFamilySub =>
      'Svako koristi svoj Apple ID. Zajednički računi nisu potrebni.';

  @override
  String get owner => 'Vlasnik';

  @override
  String get invitePending => 'Poziv čeka…';

  @override
  String get you => 'Ti';

  @override
  String get noOneConnected => 'Još niko nije povezan';

  @override
  String get noOneConnectedHint =>
      'Dodirni „Pozovi nekoga“ iznad da dijeliš\nsa partnerom ili porodicom.';

  @override
  String get howItWorks => 'Kako radi';

  @override
  String get howStep1 =>
      'Dodirni „Pozovi nekoga“ i otvara se iOS meni za dijeljenje';

  @override
  String get howStep2 => 'Pošalji link kroz Poruke, WhatsApp ili ga kopiraj';

  @override
  String get howStep3 => 'Druga osoba dodirne link, pa „Prihvati“. Gotovo.';

  @override
  String get howStep4 => 'Oba telefona se sama sinhronizuju';

  @override
  String get onbParentsTitle => 'Ko vodi djecu napolje?';

  @override
  String get onbParentsNote =>
      'Prava imena nisu potrebna: Mama i Tata, nadimci ili inicijali rade jednako dobro. Imena se vide samo u aplikaciji.';

  @override
  String get onbKidsTitle => 'A djeca?';

  @override
  String get onbKidHint1 => 'npr. Zeko';

  @override
  String get onbKidHint2 => 'npr. Tigar';

  @override
  String get onbKidsNote =>
      'I ovdje su nadimci savršeni. Sve ostaje na tvom iPhoneu i u tvom vlastitom iCloudu, nikad kod nas.';

  @override
  String get getStarted => 'Počnimo';

  @override
  String get startUsingApp => 'Počni koristiti aplikaciju';

  @override
  String get skipForNow => 'Preskoči za sada';

  @override
  String get continueLabel => 'Dalje';

  @override
  String get back => 'Nazad';

  @override
  String get onbWelcome1 =>
      'Brz dnevnik vremena koje tvoja porodica provodi napolju: ko je izveo djecu, koliko dugo i šta su radili.';

  @override
  String get onbWelcome2 =>
      'Sljedeći koraci postavljaju tvoju porodicu, neobavezne podsjetnike i planove. Traje oko minutu, a sve se kasnije može promijeniti u Postavkama.';

  @override
  String get onbWelcomeNote =>
      'Bez računa, bez reklama, bez praćenja. Tvoj dnevnik ostaje na tvom iPhoneu i u tvom vlastitom iCloudu.';

  @override
  String get name => 'Ime';

  @override
  String get addAnotherChip => '+ Dodaj još';

  @override
  String get onbRemindersIntro =>
      'Neobavezno. Mali podsjetnik jednom dnevno, u vrijeme koje odabereš. iOS traži dozvolu kad uključiš neki.';

  @override
  String get onbReminderOutside => 'Vrijeme je za napolje';

  @override
  String get onbReminderLog => 'Upiši današnju posjetu';

  @override
  String get onbRemindersLater =>
      'Ovo možeš bilo kad promijeniti u Postavke › Podsjetnici.';

  @override
  String everyDayAtChange(String time) {
    return 'Svaki dan u $time · promijeni';
  }

  @override
  String get onbPlansIntro =>
      'Neobavezno. Fudbal svakog ponedjeljka, plivanje subotom, rođendan sljedeće sedmice: planovi se pojavljuju pod Danas, spremni za štikliranje, i mogu te podsjetiti.';

  @override
  String get addAPlan => 'Dodaj plan';

  @override
  String get addAnotherPlan => 'Dodaj još jedan plan';

  @override
  String get onbPlansLater =>
      'Još planova možeš dodati bilo kad u kartici Planovi.';

  @override
  String get onbLookTitle => 'Tvoj izgled';

  @override
  String get onbLookIntro =>
      'Odaberi temu boja ili napravi svoju. Možeš je bilo kad promijeniti u Postavkama.';

  @override
  String get privInShortTitle => 'Ukratko';

  @override
  String get privInShort =>
      'Playground Tracker ne prikuplja lične podatke. Nema računa, nema našeg servera, nema analitike, reklama ni praćenja. Programer ne može vidjeti tvoj dnevnik.';

  @override
  String get privStoresTitle => 'Šta aplikacija čuva';

  @override
  String get privStores =>
      'Imena roditelja i djece koja upišeš, tvoje posjete (datum, prijepodne ili popodne, ko je išao, koja djeca, koliko dugo, aktivnosti i bilo koji razlog koji navedeš), tvoje planove i kako su prošli, te tvoje postavke. Sve se čuva u privatnoj memoriji aplikacije na tvom iPhoneu.';

  @override
  String get privICloudTitle =>
      'iCloud sinhronizacija i dijeljenje sa porodicom';

  @override
  String get privICloud =>
      'Ako si prijavljen/prijavljena na iCloud, aplikacija čuva kopiju u tvojoj vlastitoj privatnoj iCloud bazi preko Appleovog CloudKita, tako da sve ostaje usklađeno na tvojim uređajima. Ako pozoveš članove porodice linkom, pozvane osobe mogu vidjeti i uređivati zajednički dnevnik dok ne prestaneš dijeliti. iCloud podacima upravlja Apple prema Appleovoj politici privatnosti; programer nema pristup njima.';

  @override
  String get privRemindersTitle => 'Podsjetnici';

  @override
  String get privReminders =>
      'Obavijesti za podsjetnike zakazuju se na tvom iPhoneu. Ništa o njima se nigdje ne šalje. Aplikacija traži dozvolu tek kad uključiš podsjetnik.';

  @override
  String get privCalendarTitle => 'Kalendar i Podsjetnici';

  @override
  String get privCalendar =>
      '„Dodaj u Kalendar“ otvara Appleov uređivač događaja sa već popunjenim planom. Aplikacija ne čita tvoj kalendar; događaj se čuva samo ako dodirneš Dodaj. „Dodaj u Podsjetnike“ čuva plan kao jedan novi podsjetnik u tvojoj aplikaciji Podsjetnici. Aplikacija ne čita tvoje podsjetnike i ništa se nigdje ne šalje.';

  @override
  String get privChildrenTitle => 'Djeca';

  @override
  String get privChildren =>
      'Aplikacija je namijenjena roditeljima. Imena djece ostaju na tvom iPhoneu i u tvom vlastitom iCloudu. Ništa o djeci se ne šalje programeru niti bilo kome drugom.';

  @override
  String get privDeletingTitle => 'Brisanje tvojih podataka';

  @override
  String get privDeleting =>
      'Postavke › Obriši sve podatke briše sve odjednom, sa tvog iPhonea i iz tvog iClouda; ako dnevnik dijeliš sa porodicom, briše se i za njih. Pojedinačne unose možeš obrisati bilo kad, a brisanjem aplikacije briše se sve što je sačuvano na iPhoneu. Da prestaneš dijeliti, koristi Porodičnu sinhronizaciju u Postavkama.';

  @override
  String get privChangesTitle => 'Promjene';

  @override
  String get privChanges =>
      'Ako se ova politika promijeni, nova verzija dolazi sa ažuriranjem aplikacije, a datum iznad se mijenja.';

  @override
  String privacyEffective(String date) {
    return 'Važi od $date';
  }

  @override
  String get dashTapToChange => '— dodirni za promjenu';

  @override
  String get hour24Time => '24-satni format';

  @override
  String get justNow => 'upravo';

  @override
  String parentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odraslih osoba',
      few: '$count odrasle osobe',
      one: '$count odrasla osoba',
    );
    return '$_temp0';
  }

  @override
  String kidsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count djece',
      few: '$count djece',
      one: '$count dijete',
    );
    return '$_temp0';
  }

  @override
  String personRemoved(String name) {
    return '$name uklonjen/a';
  }

  @override
  String get advanced => 'Napredno';

  @override
  String get startTime => 'Početak';

  @override
  String get endTime => 'Kraj';

  @override
  String get endAfterStart => 'Kraj mora biti poslije početka';

  @override
  String timeOutside(String time) {
    return '$time napolju';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dana zaredom',
      few: 'dana zaredom',
      one: 'dan zaredom',
    );
    return '$_temp0';
  }

  @override
  String get streakDoneToday => 'Za danas urađeno';

  @override
  String get streakKeepGoing => 'Izađi danas i niz se nastavlja';

  @override
  String get streakAtRisk => 'Jučer propušteno. Izađi danas ili niz prestaje';

  @override
  String get streakStart => 'Izađi danas i započni niz';

  @override
  String get streakRule =>
      'Niz broji dane kad ste bili napolju. Jedan propušten dan se oprašta, dva zaredom ga prekidaju. Odmor ga pauzira.';

  @override
  String get goal => 'Cilj';

  @override
  String get setAGoal => 'Postavi cilj za vrijeme napolju';

  @override
  String goalOf(String done, String target) {
    return '$done od $target';
  }

  @override
  String get goalReached => 'Cilj ostvaren';

  @override
  String get goalOnTrack => 'Po planu';

  @override
  String goalBehind(String time) {
    return '$time zaostatka';
  }

  @override
  String get outdoorGoal => 'Cilj boravka napolju';

  @override
  String get goalPeriod => 'Period';

  @override
  String get hoursOutside => 'Sati napolju';

  @override
  String get otherAmount => 'Drugo';

  @override
  String get hoursHint => 'Sati, npr. 12';

  @override
  String get goalNote =>
      'Računa trajanje svake upisane posjete. Popularan cilj je 1000 sati godišnje: oko 2 sata i 45 minuta dnevno.';

  @override
  String get turnOffGoal => 'Isključi cilj';

  @override
  String get goalOff => 'Isključeno';

  @override
  String goalAWeek(String time) {
    return '$time sedmično';
  }

  @override
  String goalAMonth(String time) {
    return '$time mjesečno';
  }

  @override
  String goalAYear(String time) {
    return '$time godišnje';
  }

  @override
  String get outdoorActivity => 'Aktivnost napolju';

  @override
  String get outdoorActivitySub =>
      'Kad je urađeno, računa se kao vrijeme napolju. Isključi za stvari kao što su časovi klavira.';

  @override
  String goalSince(String date) {
    return 'Od $date';
  }
}
