import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bs.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bs'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @reasonRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get reasonRain;

  /// No description provided for @reasonSick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get reasonSick;

  /// No description provided for @reasonTooLate.
  ///
  /// In en, this message translates to:
  /// **'Too late'**
  String get reasonTooLate;

  /// No description provided for @reasonBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get reasonBusy;

  /// No description provided for @reasonCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reasonCancelled;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @visitLogged.
  ///
  /// In en, this message translates to:
  /// **'Visit logged'**
  String get visitLogged;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @recap.
  ///
  /// In en, this message translates to:
  /// **'Recap'**
  String get recap;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @addAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get addAnother;

  /// No description provided for @logAVisit.
  ///
  /// In en, this message translates to:
  /// **'Log a visit'**
  String get logAVisit;

  /// No description provided for @sameAsUsual.
  ///
  /// In en, this message translates to:
  /// **'Same as usual'**
  String get sameAsUsual;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @nobodyWentToday.
  ///
  /// In en, this message translates to:
  /// **'Nobody went today'**
  String get nobodyWentToday;

  /// No description provided for @nobodyWent.
  ///
  /// In en, this message translates to:
  /// **'Nobody went'**
  String get nobodyWent;

  /// No description provided for @onVacation.
  ///
  /// In en, this message translates to:
  /// **'On vacation'**
  String get onVacation;

  /// No description provided for @notLogged.
  ///
  /// In en, this message translates to:
  /// **'Not logged'**
  String get notLogged;

  /// No description provided for @reasonTapToChange.
  ///
  /// In en, this message translates to:
  /// **'{reason} · tap to change'**
  String reasonTapToChange(String reason);

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get tapToChange;

  /// No description provided for @plannedForToday.
  ///
  /// In en, this message translates to:
  /// **'Planned for today'**
  String get plannedForToday;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @doneOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String doneOfTotal(int done, int total);

  /// No description provided for @confirmedTapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Confirmed · tap to edit'**
  String get confirmedTapToEdit;

  /// No description provided for @skippedBecause.
  ///
  /// In en, this message translates to:
  /// **'Skipped · {reason}'**
  String skippedBecause(String reason);

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @whySkip.
  ///
  /// In en, this message translates to:
  /// **'Why skip?'**
  String get whySkip;

  /// No description provided for @whySkipHint.
  ///
  /// In en, this message translates to:
  /// **'Pick or write why “{title}” didn’t happen.'**
  String whySkipHint(String title);

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get addActivity;

  /// No description provided for @addActivityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sandpit'**
  String get addActivityHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @morningVisit.
  ///
  /// In en, this message translates to:
  /// **'Morning visit'**
  String get morningVisit;

  /// No description provided for @eveningVisit.
  ///
  /// In en, this message translates to:
  /// **'Evening visit'**
  String get eveningVisit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @whoWent.
  ///
  /// In en, this message translates to:
  /// **'Who went'**
  String get whoWent;

  /// No description provided for @whyDidntGo.
  ///
  /// In en, this message translates to:
  /// **'Why didn’t {names} go?  ·  optional'**
  String whyDidntGo(String names);

  /// No description provided for @kids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// No description provided for @howLong.
  ///
  /// In en, this message translates to:
  /// **'How long'**
  String get howLong;

  /// No description provided for @activitiesOptional.
  ///
  /// In en, this message translates to:
  /// **'Activities  ·  optional'**
  String get activitiesOptional;

  /// No description provided for @addChip.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addChip;

  /// No description provided for @onlyWhoWentRequired.
  ///
  /// In en, this message translates to:
  /// **'Only “who went” is required.'**
  String get onlyWhoWentRequired;

  /// No description provided for @prefilledMorning.
  ///
  /// In en, this message translates to:
  /// **'Prefilled from your last morning visit.'**
  String get prefilledMorning;

  /// No description provided for @prefilledEvening.
  ///
  /// In en, this message translates to:
  /// **'Prefilled from your last evening visit.'**
  String get prefilledEvening;

  /// No description provided for @updateVisit.
  ///
  /// In en, this message translates to:
  /// **'Update visit'**
  String get updateVisit;

  /// No description provided for @saveVisit.
  ///
  /// In en, this message translates to:
  /// **'Save visit'**
  String get saveVisit;

  /// No description provided for @whyNot.
  ///
  /// In en, this message translates to:
  /// **'Why not?'**
  String get whyNot;

  /// No description provided for @whyNotHint.
  ///
  /// In en, this message translates to:
  /// **'Pick or write a reason to save the day as “nobody went”.'**
  String get whyNotHint;

  /// No description provided for @writeYourOwn.
  ///
  /// In en, this message translates to:
  /// **'+ Write your own'**
  String get writeYourOwn;

  /// No description provided for @typeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grandma visiting'**
  String get typeReasonHint;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @changeReason.
  ///
  /// In en, this message translates to:
  /// **'Change reason'**
  String get changeReason;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntry;

  /// No description provided for @deleteEntryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntryQuestion;

  /// No description provided for @deleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'{date}: this also removes it on synced devices.'**
  String deleteEntryBody(String date);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @vacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get vacation;

  /// No description provided for @absentDidntGo.
  ///
  /// In en, this message translates to:
  /// **'{names} didn’t go · {reasons}'**
  String absentDidntGo(String names, String reasons);

  /// No description provided for @selectWhoWent.
  ///
  /// In en, this message translates to:
  /// **'Select who went'**
  String get selectWhoWent;

  /// No description provided for @editEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntryTitle;

  /// No description provided for @whoWentQ.
  ///
  /// In en, this message translates to:
  /// **'Who went?'**
  String get whoWentQ;

  /// No description provided for @whenQ.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get whenQ;

  /// No description provided for @howLongQ.
  ///
  /// In en, this message translates to:
  /// **'How long?'**
  String get howLongQ;

  /// No description provided for @whichKidsQ.
  ///
  /// In en, this message translates to:
  /// **'Which kids?'**
  String get whichKidsQ;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @addActivityEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Add activity…'**
  String get addActivityEllipsis;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @logEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Visits you log on Today show up here, newest first.'**
  String get logEmpty;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @playgroundVisits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{playground visit} other{playground visits}}'**
  String playgroundVisits(int count);

  /// No description provided for @outsideAsFamily.
  ///
  /// In en, this message translates to:
  /// **'{time} outside as a family'**
  String outsideAsFamily(String time);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get longestStreak;

  /// No description provided for @topActivity.
  ///
  /// In en, this message translates to:
  /// **'Top activity'**
  String get topActivity;

  /// No description provided for @wentTheMost.
  ///
  /// In en, this message translates to:
  /// **'Went the most'**
  String get wentTheMost;

  /// No description provided for @kidOutsideMost.
  ///
  /// In en, this message translates to:
  /// **'{name} got outside the most'**
  String kidOutsideMost(String name);

  /// No description provided for @taglineLots.
  ///
  /// In en, this message translates to:
  /// **'That’s a lot of fresh air. Well done!'**
  String get taglineLots;

  /// No description provided for @taglineSolid.
  ///
  /// In en, this message translates to:
  /// **'A solid {period} outside. Keep it up.'**
  String taglineSolid(String period);

  /// No description provided for @taglineEvery.
  ///
  /// In en, this message translates to:
  /// **'Every visit counts. Here’s to more of them.'**
  String get taglineEvery;

  /// No description provided for @recapEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet for {period}'**
  String recapEmpty(String period);

  /// No description provided for @recapEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Log a visit and it’ll show up here.'**
  String get recapEmptyHint;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @customiseDashboard.
  ///
  /// In en, this message translates to:
  /// **'Customise dashboard'**
  String get customiseDashboard;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @whoTookThem.
  ///
  /// In en, this message translates to:
  /// **'Who took them'**
  String get whoTookThem;

  /// No description provided for @nobodyLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody logged yet'**
  String get nobodyLoggedYet;

  /// No description provided for @kidsOutside.
  ///
  /// In en, this message translates to:
  /// **'Kids outside'**
  String get kidsOutside;

  /// No description provided for @noKidsLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No kids logged yet'**
  String get noKidsLoggedYet;

  /// No description provided for @morningEvening.
  ///
  /// In en, this message translates to:
  /// **'Morning / evening'**
  String get morningEvening;

  /// No description provided for @noVisitsThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'No visits this period'**
  String get noVisitsThisPeriod;

  /// No description provided for @visitsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Visits in {period}'**
  String visitsInPeriod(String period);

  /// No description provided for @outside.
  ///
  /// In en, this message translates to:
  /// **'Outside'**
  String get outside;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @oneSquarePerDayLower.
  ///
  /// In en, this message translates to:
  /// **'one square per day'**
  String get oneSquarePerDayLower;

  /// No description provided for @oneSquarePerMonthLower.
  ///
  /// In en, this message translates to:
  /// **'one square per month'**
  String get oneSquarePerMonthLower;

  /// No description provided for @legendBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get legendBusy;

  /// No description provided for @legendBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get legendBoth;

  /// No description provided for @legendSome.
  ///
  /// In en, this message translates to:
  /// **'Some'**
  String get legendSome;

  /// No description provided for @legendOne.
  ///
  /// In en, this message translates to:
  /// **'One'**
  String get legendOne;

  /// No description provided for @legendNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get legendNone;

  /// No description provided for @mostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get mostPlayed;

  /// No description provided for @noActivitiesLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No activities logged yet'**
  String get noActivitiesLoggedYet;

  /// No description provided for @timeAndMissedDays.
  ///
  /// In en, this message translates to:
  /// **'Time & missed days'**
  String get timeAndMissedDays;

  /// No description provided for @averageVisit.
  ///
  /// In en, this message translates to:
  /// **'Average visit'**
  String get averageVisit;

  /// No description provided for @whyNobodyWent.
  ///
  /// In en, this message translates to:
  /// **'Why nobody went'**
  String get whyNobodyWent;

  /// No description provided for @noMissedDays.
  ///
  /// In en, this message translates to:
  /// **'No missed days this period'**
  String get noMissedDays;

  /// No description provided for @noReasonsLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No reasons logged yet'**
  String get noReasonsLoggedYet;

  /// No description provided for @customiseDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Customise History'**
  String get customiseDashboardTitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder  ·  toggle to show or hide'**
  String get dragToReorder;

  /// No description provided for @oneSquarePerDay.
  ///
  /// In en, this message translates to:
  /// **'One square per day'**
  String get oneSquarePerDay;

  /// No description provided for @onceOn.
  ///
  /// In en, this message translates to:
  /// **'Once · {date}'**
  String onceOn(String date);

  /// No description provided for @noDays.
  ///
  /// In en, this message translates to:
  /// **'No days'**
  String get noDays;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// No description provided for @weekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekends;

  /// No description provided for @addedToReminders.
  ///
  /// In en, this message translates to:
  /// **'Added to Reminders'**
  String get addedToReminders;

  /// No description provided for @addedToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Added to your calendar'**
  String get addedToCalendar;

  /// No description provided for @remindersDenied.
  ///
  /// In en, this message translates to:
  /// **'Reminders access is off. Allow it in iPhone Settings.'**
  String get remindersDenied;

  /// No description provided for @calendarDenied.
  ///
  /// In en, this message translates to:
  /// **'Calendar access is off. Allow it in iPhone Settings.'**
  String get calendarDenied;

  /// No description provided for @planNoUpcomingDay.
  ///
  /// In en, this message translates to:
  /// **'This plan has no upcoming day to add'**
  String get planNoUpcomingDay;

  /// No description provided for @remindersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Reminders is only available on iPhone'**
  String get remindersUnavailable;

  /// No description provided for @calendarUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Calendar is only available on iPhone'**
  String get calendarUnavailable;

  /// No description provided for @remindersError.
  ///
  /// In en, this message translates to:
  /// **'Could not add to Reminders'**
  String get remindersError;

  /// No description provided for @calendarError.
  ///
  /// In en, this message translates to:
  /// **'Could not add to Calendar'**
  String get calendarError;

  /// No description provided for @withKids.
  ///
  /// In en, this message translates to:
  /// **'With {names}'**
  String withKids(String names);

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get editPlan;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// No description provided for @addToCalendarSub.
  ///
  /// In en, this message translates to:
  /// **'Opens iPhone Calendar — add invitees there'**
  String get addToCalendarSub;

  /// No description provided for @addToReminders.
  ///
  /// In en, this message translates to:
  /// **'Add to Reminders'**
  String get addToReminders;

  /// No description provided for @addToRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'A reminder with an alert at the plan’s time'**
  String get addToRemindersSub;

  /// No description provided for @todayNotDoneYet.
  ///
  /// In en, this message translates to:
  /// **'Today · not done yet'**
  String get todayNotDoneYet;

  /// No description provided for @planNoDaysYet.
  ///
  /// In en, this message translates to:
  /// **'No days yet. They show up here once the plan has started.'**
  String get planNoDaysYet;

  /// No description provided for @deletePlanQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete plan?'**
  String get deletePlanQuestion;

  /// No description provided for @deletePlanBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” and its whole history will be permanently deleted.'**
  String deletePlanBody(String title);

  /// No description provided for @newPlan.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get newPlan;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @reminderAt.
  ///
  /// In en, this message translates to:
  /// **'Reminder {time}'**
  String reminderAt(String time);

  /// No description provided for @tapForHistory.
  ///
  /// In en, this message translates to:
  /// **'Tap for history, Calendar and Reminders'**
  String get tapForHistory;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @noPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No plans yet'**
  String get noPlansYet;

  /// No description provided for @noPlansHint.
  ///
  /// In en, this message translates to:
  /// **'Add plans that repeat on certain days, or happen once.\nThey show up on Today.'**
  String get noPlansHint;

  /// No description provided for @addFirstPlan.
  ///
  /// In en, this message translates to:
  /// **'Add first plan'**
  String get addFirstPlan;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterTitle;

  /// No description provided for @pickADate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickADate;

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get selectAtLeastOneDay;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get planTitle;

  /// No description provided for @planTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Football'**
  String get planTitleHint;

  /// No description provided for @howOftenQ.
  ///
  /// In en, this message translates to:
  /// **'How often?'**
  String get howOftenQ;

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get oneTime;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @repeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get repeatOn;

  /// No description provided for @dateRangeOptional.
  ///
  /// In en, this message translates to:
  /// **'Date range (optional)'**
  String get dateRangeOptional;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From: {date}'**
  String fromDate(String date);

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To: {date}'**
  String toDate(String date);

  /// No description provided for @clearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get clearDates;

  /// No description provided for @reminderNotification.
  ///
  /// In en, this message translates to:
  /// **'Reminder notification'**
  String get reminderNotification;

  /// No description provided for @reminderNotificationSub.
  ///
  /// In en, this message translates to:
  /// **'Send a notification on the plan’s days'**
  String get reminderNotificationSub;

  /// No description provided for @notifyAt.
  ///
  /// In en, this message translates to:
  /// **'Notify at  {time}'**
  String notifyAt(String time);

  /// No description provided for @customMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Custom message (optional)\ne.g. Time to head out!'**
  String get customMessageHint;

  /// No description provided for @leaveEmptyDefault.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the default message.'**
  String get leaveEmptyDefault;

  /// No description provided for @timeAlreadyPassed.
  ///
  /// In en, this message translates to:
  /// **'This time has already passed, so no notification will come. Pick a later time.'**
  String get timeAlreadyPassed;

  /// No description provided for @alsoAddTo.
  ///
  /// In en, this message translates to:
  /// **'Also add to (optional)'**
  String get alsoAddTo;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @remindersApp.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersApp;

  /// No description provided for @alsoAddToHint.
  ///
  /// In en, this message translates to:
  /// **'When you save: Calendar opens with the plan filled in, so you can invite people. Reminders gets the plan with an alert at its time.'**
  String get alsoAddToHint;

  /// No description provided for @inactivePlansHidden.
  ///
  /// In en, this message translates to:
  /// **'Inactive plans are hidden from Today'**
  String get inactivePlansHidden;

  /// No description provided for @themeModernistLight.
  ///
  /// In en, this message translates to:
  /// **'Modernist light'**
  String get themeModernistLight;

  /// No description provided for @themeModernistLightSub.
  ///
  /// In en, this message translates to:
  /// **'Red and black on paper, the original'**
  String get themeModernistLightSub;

  /// No description provided for @themeModernistDark.
  ///
  /// In en, this message translates to:
  /// **'Modernist dark'**
  String get themeModernistDark;

  /// No description provided for @themeModernistDarkSub.
  ///
  /// In en, this message translates to:
  /// **'Coral on warm black'**
  String get themeModernistDarkSub;

  /// No description provided for @themeSwingLight.
  ///
  /// In en, this message translates to:
  /// **'Swing light'**
  String get themeSwingLight;

  /// No description provided for @themeSwingLightSub.
  ///
  /// In en, this message translates to:
  /// **'Deep green and orange on sunny yellow'**
  String get themeSwingLightSub;

  /// No description provided for @themeSwingDark.
  ///
  /// In en, this message translates to:
  /// **'Swing dark'**
  String get themeSwingDark;

  /// No description provided for @themeSwingDarkSub.
  ///
  /// In en, this message translates to:
  /// **'Sunny yellow on deep green'**
  String get themeSwingDarkSub;

  /// No description provided for @themeBlackOnWhite.
  ///
  /// In en, this message translates to:
  /// **'Black on white'**
  String get themeBlackOnWhite;

  /// No description provided for @themeBlackOnWhiteSub.
  ///
  /// In en, this message translates to:
  /// **'Plain black on white'**
  String get themeBlackOnWhiteSub;

  /// No description provided for @themeWhiteOnBlack.
  ///
  /// In en, this message translates to:
  /// **'White on black'**
  String get themeWhiteOnBlack;

  /// No description provided for @themeWhiteOnBlackSub.
  ///
  /// In en, this message translates to:
  /// **'Plain white on black'**
  String get themeWhiteOnBlackSub;

  /// No description provided for @themeMyColors.
  ///
  /// In en, this message translates to:
  /// **'My colors'**
  String get themeMyColors;

  /// No description provided for @themeMyColorsSub.
  ///
  /// In en, this message translates to:
  /// **'Your own background, text and accent'**
  String get themeMyColorsSub;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @parentsAndKids.
  ///
  /// In en, this message translates to:
  /// **'Parents & kids'**
  String get parentsAndKids;

  /// No description provided for @familySync.
  ///
  /// In en, this message translates to:
  /// **'Family sync'**
  String get familySync;

  /// No description provided for @familySyncSub.
  ///
  /// In en, this message translates to:
  /// **'Share across Apple IDs'**
  String get familySyncSub;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @remindersSetting.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersSetting;

  /// No description provided for @languageDateTheme.
  ///
  /// In en, this message translates to:
  /// **'Language, date & theme'**
  String get languageDateTheme;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @noDataCollected.
  ///
  /// In en, this message translates to:
  /// **'No data collected'**
  String get noDataCollected;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @logSub.
  ///
  /// In en, this message translates to:
  /// **'Every visit, newest first'**
  String get logSub;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataSub.
  ///
  /// In en, this message translates to:
  /// **'On this iPhone and in iCloud'**
  String get deleteAllDataSub;

  /// No description provided for @aboutNote.
  ///
  /// In en, this message translates to:
  /// **'Playground Tracker is a one-time App Store purchase. No subscription, no account, no ads. Your log stays on your devices and syncs through your own iCloud.'**
  String get aboutNote;

  /// No description provided for @deleteAllDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllDataQuestion;

  /// No description provided for @deleteAllDataBody.
  ///
  /// In en, this message translates to:
  /// **'Every visit, plan, name and setting is deleted from this iPhone and from your iCloud. If you share the log with family, they lose it too. This can’t be undone.'**
  String get deleteAllDataBody;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deleting;

  /// No description provided for @nothingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Nothing was deleted'**
  String get nothingDeleted;

  /// No description provided for @nothingDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'iCloud couldn’t be reached, so your data was left as it is (otherwise sync would bring it back). Try again when you’re online.'**
  String get nothingDeletedBody;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notificationsTitle;

  /// No description provided for @outdoorReminder.
  ///
  /// In en, this message translates to:
  /// **'Outdoor reminder'**
  String get outdoorReminder;

  /// No description provided for @outdoorReminderSub.
  ///
  /// In en, this message translates to:
  /// **'Did you take the kids outside today? Comes once a day at the time you choose.'**
  String get outdoorReminderSub;

  /// No description provided for @logReminder.
  ///
  /// In en, this message translates to:
  /// **'Log reminder'**
  String get logReminder;

  /// No description provided for @logReminderSub.
  ///
  /// In en, this message translates to:
  /// **'Don’t forget to log today’s playground visit. Comes once a day at the time you choose.'**
  String get logReminderSub;

  /// No description provided for @everyDayAt.
  ///
  /// In en, this message translates to:
  /// **'Every day at  {time}'**
  String everyDayAt(String time);

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Open Settings › Playground Tracker › Notifications and allow them.'**
  String get notificationsBlocked;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @notificationsLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Notifications are local, no internet needed. Each person in the family sets their own reminder times on their own phone.'**
  String get notificationsLocalNote;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @phoneLanguage.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get phoneLanguage;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get colorTheme;

  /// No description provided for @editMyColors.
  ///
  /// In en, this message translates to:
  /// **'Edit my colors'**
  String get editMyColors;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get timeFormat;

  /// No description provided for @hour12.
  ///
  /// In en, this message translates to:
  /// **'12-hour'**
  String get hour12;

  /// No description provided for @hour24.
  ///
  /// In en, this message translates to:
  /// **'24-hour'**
  String get hour24;

  /// No description provided for @changesApplyImmediately.
  ///
  /// In en, this message translates to:
  /// **'Changes apply immediately throughout the app.'**
  String get changesApplyImmediately;

  /// No description provided for @contrastTextWarning.
  ///
  /// In en, this message translates to:
  /// **'Text is hard to read on this background: contrast {ratio}:1, aim for 4.5:1 or more.'**
  String contrastTextWarning(String ratio);

  /// No description provided for @contrastAccentWarning.
  ///
  /// In en, this message translates to:
  /// **'The accent is hard to see on this background: contrast {ratio}:1, aim for 3:1 or more.'**
  String contrastAccentWarning(String ratio);

  /// No description provided for @sampleMom.
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get sampleMom;

  /// No description provided for @sampleDad.
  ///
  /// In en, this message translates to:
  /// **'Dad'**
  String get sampleDad;

  /// No description provided for @colorBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get colorBackground;

  /// No description provided for @colorText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get colorText;

  /// No description provided for @colorAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent (buttons, selections)'**
  String get colorAccent;

  /// No description provided for @notifOutdoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Playground reminder'**
  String get notifOutdoorTitle;

  /// No description provided for @notifOutdoorBody.
  ///
  /// In en, this message translates to:
  /// **'Did you take the kids outside today?'**
  String get notifOutdoorBody;

  /// No description provided for @notifLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log your outdoor time'**
  String get notifLogTitle;

  /// No description provided for @notifLogBody.
  ///
  /// In en, this message translates to:
  /// **'Don’t forget to log today’s playground visit.'**
  String get notifLogBody;

  /// No description provided for @notifPlanDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'Time for your plan'**
  String get notifPlanDefaultBody;

  /// No description provided for @addParentAndKid.
  ///
  /// In en, this message translates to:
  /// **'Add at least one parent and one kid'**
  String get addParentAndKid;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @familyEditIntro.
  ///
  /// In en, this message translates to:
  /// **'Update your family members. Existing entries are not affected.'**
  String get familyEditIntro;

  /// No description provided for @familySetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Let’s set up your family. You can always add more people later.'**
  String get familySetupIntro;

  /// No description provided for @parentsGrandparents.
  ///
  /// In en, this message translates to:
  /// **'Parents / grandparents'**
  String get parentsGrandparents;

  /// No description provided for @parentHint1.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mom'**
  String get parentHint1;

  /// No description provided for @parentHint2.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dad'**
  String get parentHint2;

  /// No description provided for @parentHintMore.
  ///
  /// In en, this message translates to:
  /// **'Parent or grandparent'**
  String get parentHintMore;

  /// No description provided for @addParent.
  ///
  /// In en, this message translates to:
  /// **'+ Add parent'**
  String get addParent;

  /// No description provided for @kidHint1.
  ///
  /// In en, this message translates to:
  /// **'e.g. Emma'**
  String get kidHint1;

  /// No description provided for @kidHint2.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tom'**
  String get kidHint2;

  /// No description provided for @kidHintMore.
  ///
  /// In en, this message translates to:
  /// **'Kid’s name'**
  String get kidHintMore;

  /// No description provided for @addKid.
  ///
  /// In en, this message translates to:
  /// **'+ Add kid'**
  String get addKid;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveAndStart.
  ///
  /// In en, this message translates to:
  /// **'Save & start'**
  String get saveAndStart;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @removeAccessQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove access?'**
  String get removeAccessQuestion;

  /// No description provided for @removeAccessBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer sync with this log. Their existing entries stay on their phone.'**
  String removeAccessBody(String name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @couldNotRemove.
  ///
  /// In en, this message translates to:
  /// **'Could not remove. Try again.'**
  String get couldNotRemove;

  /// No description provided for @connectedUser.
  ///
  /// In en, this message translates to:
  /// **'Connected user'**
  String get connectedUser;

  /// No description provided for @inviteSomeone.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteSomeone;

  /// No description provided for @inviteSub.
  ///
  /// In en, this message translates to:
  /// **'Opens the iOS share sheet: send via Messages, WhatsApp, or copy the link'**
  String get inviteSub;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String lastSynced(String time);

  /// No description provided for @shareWithFamily.
  ///
  /// In en, this message translates to:
  /// **'Share with your family'**
  String get shareWithFamily;

  /// No description provided for @shareWithFamilySub.
  ///
  /// In en, this message translates to:
  /// **'Each person uses their own Apple ID. No shared accounts needed.'**
  String get shareWithFamilySub;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @invitePending.
  ///
  /// In en, this message translates to:
  /// **'Invite pending…'**
  String get invitePending;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @noOneConnected.
  ///
  /// In en, this message translates to:
  /// **'No one connected yet'**
  String get noOneConnected;

  /// No description provided for @noOneConnectedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap “Invite someone” above to share\nwith your partner or family.'**
  String get noOneConnectedHint;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @howStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap “Invite someone” and the iOS share sheet opens'**
  String get howStep1;

  /// No description provided for @howStep2.
  ///
  /// In en, this message translates to:
  /// **'Send the link via Messages, WhatsApp, or copy it'**
  String get howStep2;

  /// No description provided for @howStep3.
  ///
  /// In en, this message translates to:
  /// **'They tap the link, then “Accept”. Done.'**
  String get howStep3;

  /// No description provided for @howStep4.
  ///
  /// In en, this message translates to:
  /// **'Both phones stay in sync automatically'**
  String get howStep4;

  /// No description provided for @onbParentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Who takes the kids out?'**
  String get onbParentsTitle;

  /// No description provided for @onbParentsNote.
  ///
  /// In en, this message translates to:
  /// **'Real names aren’t needed: Mom and Dad, nicknames or initials work just as well. Names only appear in the app.'**
  String get onbParentsNote;

  /// No description provided for @onbKidsTitle.
  ///
  /// In en, this message translates to:
  /// **'And the kids?'**
  String get onbKidsTitle;

  /// No description provided for @onbKidHint1.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bean'**
  String get onbKidHint1;

  /// No description provided for @onbKidHint2.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tiger'**
  String get onbKidHint2;

  /// No description provided for @onbKidsNote.
  ///
  /// In en, this message translates to:
  /// **'Nicknames are perfect here too. Everything stays on your iPhone and in your own iCloud, never with us.'**
  String get onbKidsNote;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @startUsingApp.
  ///
  /// In en, this message translates to:
  /// **'Start using the app'**
  String get startUsingApp;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @onbWelcome1.
  ///
  /// In en, this message translates to:
  /// **'A quick log of your family’s outdoor time: who took the kids out, for how long, and what they did.'**
  String get onbWelcome1;

  /// No description provided for @onbWelcome2.
  ///
  /// In en, this message translates to:
  /// **'The next few steps set up your family, optional reminders and plans. It takes about a minute, and everything can be changed later in Settings.'**
  String get onbWelcome2;

  /// No description provided for @onbWelcomeNote.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads, no tracking. Your log stays on your iPhone and in your own iCloud.'**
  String get onbWelcomeNote;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @addAnotherChip.
  ///
  /// In en, this message translates to:
  /// **'+ Add another'**
  String get addAnotherChip;

  /// No description provided for @onbRemindersIntro.
  ///
  /// In en, this message translates to:
  /// **'Optional. A gentle nudge once a day, at a time you choose. iOS asks for permission when you switch one on.'**
  String get onbRemindersIntro;

  /// No description provided for @onbReminderOutside.
  ///
  /// In en, this message translates to:
  /// **'Time to go outside'**
  String get onbReminderOutside;

  /// No description provided for @onbReminderLog.
  ///
  /// In en, this message translates to:
  /// **'Log today’s visit'**
  String get onbReminderLog;

  /// No description provided for @onbRemindersLater.
  ///
  /// In en, this message translates to:
  /// **'You can change these any time in Settings › Reminders.'**
  String get onbRemindersLater;

  /// No description provided for @everyDayAtChange.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time} · change'**
  String everyDayAtChange(String time);

  /// No description provided for @onbPlansIntro.
  ///
  /// In en, this message translates to:
  /// **'Optional. Football every Monday, swimming on Saturdays, a birthday party next week: plans show up on Today, ready to tick off, and can remind you.'**
  String get onbPlansIntro;

  /// No description provided for @addAPlan.
  ///
  /// In en, this message translates to:
  /// **'Add a plan'**
  String get addAPlan;

  /// No description provided for @addAnotherPlan.
  ///
  /// In en, this message translates to:
  /// **'Add another plan'**
  String get addAnotherPlan;

  /// No description provided for @onbPlansLater.
  ///
  /// In en, this message translates to:
  /// **'You can add more any time in the Plans tab.'**
  String get onbPlansLater;

  /// No description provided for @onbLookTitle.
  ///
  /// In en, this message translates to:
  /// **'Your look'**
  String get onbLookTitle;

  /// No description provided for @onbLookIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick a color theme, or make your own. You can change it any time in Settings.'**
  String get onbLookIntro;

  /// No description provided for @privInShortTitle.
  ///
  /// In en, this message translates to:
  /// **'In short'**
  String get privInShortTitle;

  /// No description provided for @privInShort.
  ///
  /// In en, this message translates to:
  /// **'Playground Tracker does not collect personal data. There is no account, no server of ours, no analytics, no advertising and no tracking. The developer cannot see your log.'**
  String get privInShort;

  /// No description provided for @privStoresTitle.
  ///
  /// In en, this message translates to:
  /// **'What the app stores'**
  String get privStoresTitle;

  /// No description provided for @privStores.
  ///
  /// In en, this message translates to:
  /// **'The names of the parents and kids you enter, your visits (date, morning or evening, who went, which kids, how long, activities, and any reason you give), your plans and how they went, and your settings. All of it is kept in the app’s private storage on your iPhone.'**
  String get privStores;

  /// No description provided for @privICloudTitle.
  ///
  /// In en, this message translates to:
  /// **'iCloud sync and family sharing'**
  String get privICloudTitle;

  /// No description provided for @privICloud.
  ///
  /// In en, this message translates to:
  /// **'If you are signed in to iCloud, the app keeps a copy in your own private iCloud database through Apple’s CloudKit, so it stays in sync across your devices. If you invite family members with a share link, the people you invite can see and edit the shared log until you stop sharing. iCloud data is handled by Apple under Apple’s privacy policy; the developer has no access to it.'**
  String get privICloud;

  /// No description provided for @privRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get privRemindersTitle;

  /// No description provided for @privReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications are scheduled on your iPhone. Nothing about them is sent anywhere. The app asks for permission only when you turn a reminder on.'**
  String get privReminders;

  /// No description provided for @privCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar and Reminders'**
  String get privCalendarTitle;

  /// No description provided for @privCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar opens Apple’s own event editor with the plan filled in. The app does not read your calendar; the event is saved only if you tap Add. Add to Reminders saves the plan as one new reminder in your Reminders app. The app does not read your reminders and nothing is sent anywhere.'**
  String get privCalendar;

  /// No description provided for @privChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get privChildrenTitle;

  /// No description provided for @privChildren.
  ///
  /// In en, this message translates to:
  /// **'The app is meant for parents. Children’s names stay on your iPhone and in your own iCloud. Nothing about children is sent to the developer or to anyone else.'**
  String get privChildren;

  /// No description provided for @privDeletingTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privDeletingTitle;

  /// No description provided for @privDeleting.
  ///
  /// In en, this message translates to:
  /// **'Settings › Delete all data removes everything at once, from your iPhone and from your iCloud; if you share the log with family, it is removed for them too. You can also delete single entries at any time, and deleting the app removes everything stored on the iPhone. To stop sharing, use Family sync in Settings.'**
  String get privDeleting;

  /// No description provided for @privChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get privChangesTitle;

  /// No description provided for @privChanges.
  ///
  /// In en, this message translates to:
  /// **'If this policy changes, the new version ships with an app update and its effective date changes above.'**
  String get privChanges;

  /// No description provided for @privacyEffective.
  ///
  /// In en, this message translates to:
  /// **'Effective {date}'**
  String privacyEffective(String date);

  /// No description provided for @dashTapToChange.
  ///
  /// In en, this message translates to:
  /// **'— tap to change'**
  String get dashTapToChange;

  /// No description provided for @hour24Time.
  ///
  /// In en, this message translates to:
  /// **'24-hour time'**
  String get hour24Time;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @parentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 parent} other{{count} parents}}'**
  String parentsCount(int count);

  /// No description provided for @kidsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 kid} other{{count} kids}}'**
  String kidsCount(int count);

  /// No description provided for @personRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String personRemoved(String name);

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTime;

  /// No description provided for @endAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End has to be after start'**
  String get endAfterStart;

  /// No description provided for @timeOutside.
  ///
  /// In en, this message translates to:
  /// **'{time} outside'**
  String timeOutside(String time);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day streak} other{day streak}}'**
  String streakDays(int count);

  /// No description provided for @streakDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get streakDoneToday;

  /// No description provided for @streakKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Go out today to keep it going'**
  String get streakKeepGoing;

  /// No description provided for @streakAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Missed yesterday. Go out today to keep it'**
  String get streakAtRisk;

  /// No description provided for @streakStart.
  ///
  /// In en, this message translates to:
  /// **'Go out today to start one'**
  String get streakStart;

  /// No description provided for @streakRule.
  ///
  /// In en, this message translates to:
  /// **'A streak counts the days you went out. One missed day is forgiven, two in a row end it. Vacation days pause it.'**
  String get streakRule;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @setAGoal.
  ///
  /// In en, this message translates to:
  /// **'Set an outdoor goal'**
  String get setAGoal;

  /// No description provided for @goalOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {target}'**
  String goalOf(String done, String target);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @goalOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get goalOnTrack;

  /// No description provided for @goalBehind.
  ///
  /// In en, this message translates to:
  /// **'{time} behind'**
  String goalBehind(String time);

  /// No description provided for @outdoorGoal.
  ///
  /// In en, this message translates to:
  /// **'Outdoor goal'**
  String get outdoorGoal;

  /// No description provided for @goalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get goalPeriod;

  /// No description provided for @hoursOutside.
  ///
  /// In en, this message translates to:
  /// **'Hours outside'**
  String get hoursOutside;

  /// No description provided for @otherAmount.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherAmount;

  /// No description provided for @hoursHint.
  ///
  /// In en, this message translates to:
  /// **'Hours, e.g. 12'**
  String get hoursHint;

  /// No description provided for @goalNote.
  ///
  /// In en, this message translates to:
  /// **'Counts the length of every visit you log. A popular goal is 1000 hours a year: about 2 hours 45 minutes a day.'**
  String get goalNote;

  /// No description provided for @turnOffGoal.
  ///
  /// In en, this message translates to:
  /// **'Turn off goal'**
  String get turnOffGoal;

  /// No description provided for @goalOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get goalOff;

  /// No description provided for @goalAWeek.
  ///
  /// In en, this message translates to:
  /// **'{time} a week'**
  String goalAWeek(String time);

  /// No description provided for @goalAMonth.
  ///
  /// In en, this message translates to:
  /// **'{time} a month'**
  String goalAMonth(String time);

  /// No description provided for @goalAYear.
  ///
  /// In en, this message translates to:
  /// **'{time} a year'**
  String goalAYear(String time);

  /// No description provided for @outdoorActivity.
  ///
  /// In en, this message translates to:
  /// **'Outdoor activity'**
  String get outdoorActivity;

  /// No description provided for @outdoorActivitySub.
  ///
  /// In en, this message translates to:
  /// **'Done counts as time outside. Turn off for things like piano lessons.'**
  String get outdoorActivitySub;

  /// No description provided for @goalSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String goalSince(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bs', 'cs', 'de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return AppLocalizationsBs();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
