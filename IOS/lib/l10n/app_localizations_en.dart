// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get reasonRain => 'Rain';

  @override
  String get reasonSick => 'Sick';

  @override
  String get reasonTooLate => 'Too late';

  @override
  String get reasonBusy => 'Busy';

  @override
  String get reasonCancelled => 'Cancelled';

  @override
  String get reasonOther => 'Other';

  @override
  String get today => 'Today';

  @override
  String get history => 'History';

  @override
  String get plans => 'Plans';

  @override
  String get settings => 'Settings';

  @override
  String get visitLogged => 'Visit logged';

  @override
  String get edit => 'Edit';

  @override
  String get recap => 'Recap';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get addAnother => 'Add another';

  @override
  String get logAVisit => 'Log a visit';

  @override
  String get sameAsUsual => 'Same as usual';

  @override
  String get morning => 'Morning';

  @override
  String get evening => 'Evening';

  @override
  String get nobodyWentToday => 'Nobody went today';

  @override
  String get nobodyWent => 'Nobody went';

  @override
  String get onVacation => 'On vacation';

  @override
  String get notLogged => 'Not logged';

  @override
  String reasonTapToChange(String reason) {
    return '$reason · tap to change';
  }

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get plannedForToday => 'Planned for today';

  @override
  String get planned => 'Planned';

  @override
  String doneOfTotal(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get confirmedTapToEdit => 'Confirmed · tap to edit';

  @override
  String skippedBecause(String reason) {
    return 'Skipped · $reason';
  }

  @override
  String get skipped => 'Skipped';

  @override
  String get missed => 'Missed';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get whySkip => 'Why skip?';

  @override
  String whySkipHint(String title) {
    return 'Pick or write why “$title” didn’t happen.';
  }

  @override
  String get addActivity => 'Add activity';

  @override
  String get addActivityHint => 'e.g. Sandpit';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get morningVisit => 'Morning visit';

  @override
  String get eveningVisit => 'Evening visit';

  @override
  String get save => 'Save';

  @override
  String get whoWent => 'Who went';

  @override
  String whyDidntGo(String names) {
    return 'Why didn’t $names go?  ·  optional';
  }

  @override
  String get kids => 'Kids';

  @override
  String get howLong => 'How long';

  @override
  String get activitiesOptional => 'Activities  ·  optional';

  @override
  String get addChip => '+ Add';

  @override
  String get onlyWhoWentRequired => 'Only “who went” is required.';

  @override
  String get prefilledMorning => 'Prefilled from your last morning visit.';

  @override
  String get prefilledEvening => 'Prefilled from your last evening visit.';

  @override
  String get updateVisit => 'Update visit';

  @override
  String get saveVisit => 'Save visit';

  @override
  String get whyNot => 'Why not?';

  @override
  String get whyNotHint =>
      'Pick or write a reason to save the day as “nobody went”.';

  @override
  String get writeYourOwn => '+ Write your own';

  @override
  String get typeReasonHint => 'e.g. Grandma visiting';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get changeReason => 'Change reason';

  @override
  String get deleteEntry => 'Delete entry';

  @override
  String get deleteEntryQuestion => 'Delete entry?';

  @override
  String deleteEntryBody(String date) {
    return '$date: this also removes it on synced devices.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get undo => 'Undo';

  @override
  String get vacation => 'Vacation';

  @override
  String absentDidntGo(String names, String reasons) {
    return '$names didn’t go · $reasons';
  }

  @override
  String get selectWhoWent => 'Select who went';

  @override
  String get editEntryTitle => 'Edit entry';

  @override
  String get whoWentQ => 'Who went?';

  @override
  String get whenQ => 'When?';

  @override
  String get howLongQ => 'How long?';

  @override
  String get whichKidsQ => 'Which kids?';

  @override
  String get activities => 'Activities';

  @override
  String get addActivityEllipsis => 'Add activity…';

  @override
  String get log => 'Log';

  @override
  String get logEmpty =>
      'Nothing logged yet. Visits you log on Today show up here, newest first.';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String playgroundVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'playground visits',
      one: 'playground visit',
    );
    return '$_temp0';
  }

  @override
  String outsideAsFamily(String time) {
    return '$time outside as a family';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get longestStreak => 'Longest streak';

  @override
  String get topActivity => 'Top activity';

  @override
  String get wentTheMost => 'Went the most';

  @override
  String kidOutsideMost(String name) {
    return '$name got outside the most';
  }

  @override
  String get taglineLots => 'That’s a lot of fresh air. Well done!';

  @override
  String taglineSolid(String period) {
    return 'A solid $period outside. Keep it up.';
  }

  @override
  String get taglineEvery => 'Every visit counts. Here’s to more of them.';

  @override
  String recapEmpty(String period) {
    return 'Nothing logged yet for $period';
  }

  @override
  String get recapEmptyHint => 'Log a visit and it’ll show up here.';

  @override
  String get allTime => 'All time';

  @override
  String get customiseDashboard => 'Customise dashboard';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get all => 'All';

  @override
  String get whoTookThem => 'Who took them';

  @override
  String get nobodyLoggedYet => 'Nobody logged yet';

  @override
  String get kidsOutside => 'Kids outside';

  @override
  String get noKidsLoggedYet => 'No kids logged yet';

  @override
  String get morningEvening => 'Morning / evening';

  @override
  String get noVisitsThisPeriod => 'No visits this period';

  @override
  String visitsInPeriod(String period) {
    return 'Visits in $period';
  }

  @override
  String get outside => 'Outside';

  @override
  String get thisWeek => 'This week';

  @override
  String get oneSquarePerDayLower => 'one square per day';

  @override
  String get oneSquarePerMonthLower => 'one square per month';

  @override
  String get legendBusy => 'Busy';

  @override
  String get legendBoth => 'Both';

  @override
  String get legendSome => 'Some';

  @override
  String get legendOne => 'One';

  @override
  String get legendNone => 'None';

  @override
  String get mostPlayed => 'Most played';

  @override
  String get noActivitiesLoggedYet => 'No activities logged yet';

  @override
  String get timeAndMissedDays => 'Time & missed days';

  @override
  String get averageVisit => 'Average visit';

  @override
  String get whyNobodyWent => 'Why nobody went';

  @override
  String get noMissedDays => 'No missed days this period';

  @override
  String get noReasonsLoggedYet => 'No reasons logged yet';

  @override
  String get customiseDashboardTitle => 'Customise History';

  @override
  String get reset => 'Reset';

  @override
  String get dragToReorder => 'Drag to reorder  ·  toggle to show or hide';

  @override
  String get oneSquarePerDay => 'One square per day';

  @override
  String onceOn(String date) {
    return 'Once · $date';
  }

  @override
  String get noDays => 'No days';

  @override
  String get everyDay => 'Every day';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get weekends => 'Weekends';

  @override
  String get addedToReminders => 'Added to Reminders';

  @override
  String get addedToCalendar => 'Added to your calendar';

  @override
  String get remindersDenied =>
      'Reminders access is off. Allow it in iPhone Settings.';

  @override
  String get calendarDenied =>
      'Calendar access is off. Allow it in iPhone Settings.';

  @override
  String get planNoUpcomingDay => 'This plan has no upcoming day to add';

  @override
  String get remindersUnavailable => 'Reminders is only available on iPhone';

  @override
  String get calendarUnavailable => 'Calendar is only available on iPhone';

  @override
  String get remindersError => 'Could not add to Reminders';

  @override
  String get calendarError => 'Could not add to Calendar';

  @override
  String withKids(String names) {
    return 'With $names';
  }

  @override
  String get editPlan => 'Edit plan';

  @override
  String get addToCalendar => 'Add to Calendar';

  @override
  String get addToCalendarSub => 'Opens iPhone Calendar — add invitees there';

  @override
  String get addToReminders => 'Add to Reminders';

  @override
  String get addToRemindersSub => 'A reminder with an alert at the plan’s time';

  @override
  String get todayNotDoneYet => 'Today · not done yet';

  @override
  String get planNoDaysYet =>
      'No days yet. They show up here once the plan has started.';

  @override
  String get deletePlanQuestion => 'Delete plan?';

  @override
  String deletePlanBody(String title) {
    return '“$title” and its whole history will be permanently deleted.';
  }

  @override
  String get newPlan => 'New plan';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String reminderAt(String time) {
    return 'Reminder $time';
  }

  @override
  String get tapForHistory => 'Tap for history, Calendar and Reminders';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get noPlansYet => 'No plans yet';

  @override
  String get noPlansHint =>
      'Add plans that repeat on certain days, or happen once.\nThey show up on Today.';

  @override
  String get addFirstPlan => 'Add first plan';

  @override
  String get enterTitle => 'Enter a title';

  @override
  String get pickADate => 'Pick a date';

  @override
  String get selectAtLeastOneDay => 'Select at least one day';

  @override
  String get notSet => 'Not set';

  @override
  String get planTitle => 'Title';

  @override
  String get planTitleHint => 'e.g. Football';

  @override
  String get howOftenQ => 'How often?';

  @override
  String get repeats => 'Repeats';

  @override
  String get oneTime => 'One time';

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get repeatOn => 'Repeat on';

  @override
  String get dateRangeOptional => 'Date range (optional)';

  @override
  String fromDate(String date) {
    return 'From: $date';
  }

  @override
  String toDate(String date) {
    return 'To: $date';
  }

  @override
  String get clearDates => 'Clear dates';

  @override
  String get reminderNotification => 'Reminder notification';

  @override
  String get reminderNotificationSub =>
      'Send a notification on the plan’s days';

  @override
  String notifyAt(String time) {
    return 'Notify at  $time';
  }

  @override
  String get customMessageHint =>
      'Custom message (optional)\ne.g. Time to head out!';

  @override
  String get leaveEmptyDefault => 'Leave empty to use the default message.';

  @override
  String get timeAlreadyPassed =>
      'This time has already passed, so no notification will come. Pick a later time.';

  @override
  String get alsoAddTo => 'Also add to (optional)';

  @override
  String get calendar => 'Calendar';

  @override
  String get remindersApp => 'Reminders';

  @override
  String get alsoAddToHint =>
      'When you save: Calendar opens with the plan filled in, so you can invite people. Reminders gets the plan with an alert at its time.';

  @override
  String get inactivePlansHidden => 'Inactive plans are hidden from Today';

  @override
  String get themeModernistLight => 'Modernist light';

  @override
  String get themeModernistLightSub => 'Red and black on paper, the original';

  @override
  String get themeModernistDark => 'Modernist dark';

  @override
  String get themeModernistDarkSub => 'Coral on warm black';

  @override
  String get themeSwingLight => 'Swing light';

  @override
  String get themeSwingLightSub => 'Deep green and orange on sunny yellow';

  @override
  String get themeSwingDark => 'Swing dark';

  @override
  String get themeSwingDarkSub => 'Sunny yellow on deep green';

  @override
  String get themeBlackOnWhite => 'Black on white';

  @override
  String get themeBlackOnWhiteSub => 'Plain black on white';

  @override
  String get themeWhiteOnBlack => 'White on black';

  @override
  String get themeWhiteOnBlackSub => 'Plain white on black';

  @override
  String get themeMyColors => 'My colors';

  @override
  String get themeMyColorsSub => 'Your own background, text and accent';

  @override
  String get family => 'Family';

  @override
  String get parentsAndKids => 'Parents & kids';

  @override
  String get familySync => 'Family sync';

  @override
  String get familySyncSub => 'Share across Apple IDs';

  @override
  String get app => 'App';

  @override
  String get remindersSetting => 'Reminders';

  @override
  String get languageDateTheme => 'Language, date & theme';

  @override
  String get privacy => 'Privacy';

  @override
  String get noDataCollected => 'No data collected';

  @override
  String get yourData => 'Your data';

  @override
  String get logSub => 'Every visit, newest first';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllDataSub => 'On this iPhone and in iCloud';

  @override
  String get aboutNote =>
      'Playground Tracker is a one-time App Store purchase. No subscription, no account, no ads. Your log stays on your devices and syncs through your own iCloud.';

  @override
  String get deleteAllDataQuestion => 'Delete all data?';

  @override
  String get deleteAllDataBody =>
      'Every visit, plan, name and setting is deleted from this iPhone and from your iCloud. If you share the log with family, they lose it too. This can’t be undone.';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get deleting => 'Deleting…';

  @override
  String get nothingDeleted => 'Nothing was deleted';

  @override
  String get nothingDeletedBody =>
      'iCloud couldn’t be reached, so your data was left as it is (otherwise sync would bring it back). Try again when you’re online.';

  @override
  String get ok => 'OK';

  @override
  String get notificationsTitle => 'Reminders';

  @override
  String get outdoorReminder => 'Outdoor reminder';

  @override
  String get outdoorReminderSub =>
      'Did you take the kids outside today? Comes once a day at the time you choose.';

  @override
  String get logReminder => 'Log reminder';

  @override
  String get logReminderSub =>
      'Don’t forget to log today’s playground visit. Comes once a day at the time you choose.';

  @override
  String everyDayAt(String time) {
    return 'Every day at  $time';
  }

  @override
  String get notificationsBlocked =>
      'Notifications are blocked. Open Settings › Playground Tracker › Notifications and allow them.';

  @override
  String get retry => 'Retry';

  @override
  String get notificationsLocalNote =>
      'Notifications are local, no internet needed. Each person in the family sets their own reminder times on their own phone.';

  @override
  String get language => 'Language';

  @override
  String get phoneLanguage => 'Phone language';

  @override
  String get colorTheme => 'Color theme';

  @override
  String get editMyColors => 'Edit my colors';

  @override
  String get timeFormat => 'Time format';

  @override
  String get hour12 => '12-hour';

  @override
  String get hour24 => '24-hour';

  @override
  String get changesApplyImmediately =>
      'Changes apply immediately throughout the app.';

  @override
  String contrastTextWarning(String ratio) {
    return 'Text is hard to read on this background: contrast $ratio:1, aim for 4.5:1 or more.';
  }

  @override
  String contrastAccentWarning(String ratio) {
    return 'The accent is hard to see on this background: contrast $ratio:1, aim for 3:1 or more.';
  }

  @override
  String get sampleMom => 'Mom';

  @override
  String get sampleDad => 'Dad';

  @override
  String get colorBackground => 'Background';

  @override
  String get colorText => 'Text';

  @override
  String get colorAccent => 'Accent (buttons, selections)';

  @override
  String get notifOutdoorTitle => 'Playground reminder';

  @override
  String get notifOutdoorBody => 'Did you take the kids outside today?';

  @override
  String get notifLogTitle => 'Log your outdoor time';

  @override
  String get notifLogBody => 'Don’t forget to log today’s playground visit.';

  @override
  String get notifPlanDefaultBody => 'Time for your plan';

  @override
  String get addParentAndKid => 'Add at least one parent and one kid';

  @override
  String get welcome => 'Welcome';

  @override
  String get familyEditIntro =>
      'Update your family members. Existing entries are not affected.';

  @override
  String get familySetupIntro =>
      'Let’s set up your family. You can always add more people later.';

  @override
  String get parentsGrandparents => 'Parents / grandparents';

  @override
  String get parentHint1 => 'e.g. Mom';

  @override
  String get parentHint2 => 'e.g. Dad';

  @override
  String get parentHintMore => 'Parent or grandparent';

  @override
  String get addParent => '+ Add parent';

  @override
  String get kidHint1 => 'e.g. Emma';

  @override
  String get kidHint2 => 'e.g. Tom';

  @override
  String get kidHintMore => 'Kid’s name';

  @override
  String get addKid => '+ Add kid';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveAndStart => 'Save & start';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get removeAccessQuestion => 'Remove access?';

  @override
  String removeAccessBody(String name) {
    return '$name will no longer sync with this log. Their existing entries stay on their phone.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get couldNotRemove => 'Could not remove. Try again.';

  @override
  String get connectedUser => 'Connected user';

  @override
  String get inviteSomeone => 'Invite someone';

  @override
  String get inviteSub =>
      'Opens the iOS share sheet: send via Messages, WhatsApp, or copy the link';

  @override
  String get connected => 'Connected';

  @override
  String lastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String get shareWithFamily => 'Share with your family';

  @override
  String get shareWithFamilySub =>
      'Each person uses their own Apple ID. No shared accounts needed.';

  @override
  String get owner => 'Owner';

  @override
  String get invitePending => 'Invite pending…';

  @override
  String get you => 'You';

  @override
  String get noOneConnected => 'No one connected yet';

  @override
  String get noOneConnectedHint =>
      'Tap “Invite someone” above to share\nwith your partner or family.';

  @override
  String get howItWorks => 'How it works';

  @override
  String get howStep1 => 'Tap “Invite someone” and the iOS share sheet opens';

  @override
  String get howStep2 => 'Send the link via Messages, WhatsApp, or copy it';

  @override
  String get howStep3 => 'They tap the link, then “Accept”. Done.';

  @override
  String get howStep4 => 'Both phones stay in sync automatically';

  @override
  String get onbParentsTitle => 'Who takes the kids out?';

  @override
  String get onbParentsNote =>
      'Real names aren’t needed: Mom and Dad, nicknames or initials work just as well. Names only appear in the app.';

  @override
  String get onbKidsTitle => 'And the kids?';

  @override
  String get onbKidHint1 => 'e.g. Bean';

  @override
  String get onbKidHint2 => 'e.g. Tiger';

  @override
  String get onbKidsNote =>
      'Nicknames are perfect here too. Everything stays on your iPhone and in your own iCloud, never with us.';

  @override
  String get getStarted => 'Get started';

  @override
  String get startUsingApp => 'Start using the app';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get continueLabel => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get onbWelcome1 =>
      'A quick log of your family’s outdoor time: who took the kids out, for how long, and what they did.';

  @override
  String get onbWelcome2 =>
      'The next few steps set up your family, optional reminders and plans. It takes about a minute, and everything can be changed later in Settings.';

  @override
  String get onbWelcomeNote =>
      'No account, no ads, no tracking. Your log stays on your iPhone and in your own iCloud.';

  @override
  String get name => 'Name';

  @override
  String get addAnotherChip => '+ Add another';

  @override
  String get onbRemindersIntro =>
      'Optional. A gentle nudge once a day, at a time you choose. iOS asks for permission when you switch one on.';

  @override
  String get onbReminderOutside => 'Time to go outside';

  @override
  String get onbReminderLog => 'Log today’s visit';

  @override
  String get onbRemindersLater =>
      'You can change these any time in Settings › Reminders.';

  @override
  String everyDayAtChange(String time) {
    return 'Every day at $time · change';
  }

  @override
  String get onbPlansIntro =>
      'Optional. Football every Monday, swimming on Saturdays, a birthday party next week: plans show up on Today, ready to tick off, and can remind you.';

  @override
  String get addAPlan => 'Add a plan';

  @override
  String get addAnotherPlan => 'Add another plan';

  @override
  String get onbPlansLater => 'You can add more any time in the Plans tab.';

  @override
  String get onbLookTitle => 'Your look';

  @override
  String get onbLookIntro =>
      'Pick a color theme, or make your own. You can change it any time in Settings.';

  @override
  String get privInShortTitle => 'In short';

  @override
  String get privInShort =>
      'Playground Tracker does not collect personal data. There is no account, no server of ours, no analytics, no advertising and no tracking. The developer cannot see your log.';

  @override
  String get privStoresTitle => 'What the app stores';

  @override
  String get privStores =>
      'The names of the parents and kids you enter, your visits (date, morning or evening, who went, which kids, how long, activities, and any reason you give), your plans and how they went, and your settings. All of it is kept in the app’s private storage on your iPhone.';

  @override
  String get privICloudTitle => 'iCloud sync and family sharing';

  @override
  String get privICloud =>
      'If you are signed in to iCloud, the app keeps a copy in your own private iCloud database through Apple’s CloudKit, so it stays in sync across your devices. If you invite family members with a share link, the people you invite can see and edit the shared log until you stop sharing. iCloud data is handled by Apple under Apple’s privacy policy; the developer has no access to it.';

  @override
  String get privRemindersTitle => 'Reminders';

  @override
  String get privReminders =>
      'Reminder notifications are scheduled on your iPhone. Nothing about them is sent anywhere. The app asks for permission only when you turn a reminder on.';

  @override
  String get privCalendarTitle => 'Calendar and Reminders';

  @override
  String get privCalendar =>
      'Add to Calendar opens Apple’s own event editor with the plan filled in. The app does not read your calendar; the event is saved only if you tap Add. Add to Reminders saves the plan as one new reminder in your Reminders app. The app does not read your reminders and nothing is sent anywhere.';

  @override
  String get privChildrenTitle => 'Children';

  @override
  String get privChildren =>
      'The app is meant for parents. Children’s names stay on your iPhone and in your own iCloud. Nothing about children is sent to the developer or to anyone else.';

  @override
  String get privDeletingTitle => 'Deleting your data';

  @override
  String get privDeleting =>
      'Settings › Delete all data removes everything at once, from your iPhone and from your iCloud; if you share the log with family, it is removed for them too. You can also delete single entries at any time, and deleting the app removes everything stored on the iPhone. To stop sharing, use Family sync in Settings.';

  @override
  String get privChangesTitle => 'Changes';

  @override
  String get privChanges =>
      'If this policy changes, the new version ships with an app update and its effective date changes above.';

  @override
  String privacyEffective(String date) {
    return 'Effective $date';
  }

  @override
  String get dashTapToChange => '— tap to change';

  @override
  String get hour24Time => '24-hour time';

  @override
  String get justNow => 'just now';

  @override
  String parentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parents',
      one: '1 parent',
    );
    return '$_temp0';
  }

  @override
  String kidsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kids',
      one: '1 kid',
    );
    return '$_temp0';
  }

  @override
  String personRemoved(String name) {
    return '$name removed';
  }
}
