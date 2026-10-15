// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get reasonRain => 'Lluvia';

  @override
  String get reasonSick => 'Enfermedad';

  @override
  String get reasonTooLate => 'Muy tarde';

  @override
  String get reasonBusy => 'Sin tiempo';

  @override
  String get reasonCancelled => 'Cancelado';

  @override
  String get reasonOther => 'Otro';

  @override
  String get today => 'Hoy';

  @override
  String get history => 'Historial';

  @override
  String get plans => 'Planes';

  @override
  String get settings => 'Ajustes';

  @override
  String get visitLogged => 'Visita registrada';

  @override
  String get edit => 'Editar';

  @override
  String get recap => 'Resumen';

  @override
  String get yesterday => 'Ayer';

  @override
  String get addAnother => 'Añadir otra';

  @override
  String get logAVisit => 'Registrar una visita';

  @override
  String get sameAsUsual => 'Lo de siempre';

  @override
  String get morning => 'Mañana';

  @override
  String get evening => 'Tarde';

  @override
  String get nobodyWentToday => 'Hoy no fue nadie';

  @override
  String get nobodyWent => 'No fue nadie';

  @override
  String get onVacation => 'De vacaciones';

  @override
  String get notLogged => 'Sin registrar';

  @override
  String reasonTapToChange(String reason) {
    return '$reason · toca para cambiar';
  }

  @override
  String get tapToChange => 'Toca para cambiar';

  @override
  String get plannedForToday => 'Planes de hoy';

  @override
  String get planned => 'Planes';

  @override
  String doneOfTotal(int done, int total) {
    return '$done de $total hechos';
  }

  @override
  String get confirmedTapToEdit => 'Confirmado · toca para editar';

  @override
  String skippedBecause(String reason) {
    return 'Omitido · $reason';
  }

  @override
  String get skipped => 'Omitido';

  @override
  String get missed => 'Perdido';

  @override
  String get done => 'Hecho';

  @override
  String get skip => 'Omitir';

  @override
  String get whySkip => '¿Por qué lo omites?';

  @override
  String whySkipHint(String title) {
    return 'Elige o escribe por qué no se hizo “$title”.';
  }

  @override
  String get addActivity => 'Añadir actividad';

  @override
  String get addActivityHint => 'p. ej. Arenero';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Añadir';

  @override
  String get morningVisit => 'Visita de la mañana';

  @override
  String get eveningVisit => 'Visita de la tarde';

  @override
  String get save => 'Guardar';

  @override
  String get whoWent => 'Quién fue';

  @override
  String whyDidntGo(String names) {
    return '¿Por qué no fue $names?  ·  opcional';
  }

  @override
  String get kids => 'Niños';

  @override
  String get howLong => 'Cuánto tiempo';

  @override
  String get activitiesOptional => 'Actividades  ·  opcional';

  @override
  String get addChip => '+ Añadir';

  @override
  String get onlyWhoWentRequired => 'Solo “quién fue” es obligatorio.';

  @override
  String get prefilledMorning => 'Rellenado con tu última visita de la mañana.';

  @override
  String get prefilledEvening => 'Rellenado con tu última visita de la tarde.';

  @override
  String get updateVisit => 'Actualizar visita';

  @override
  String get saveVisit => 'Guardar visita';

  @override
  String get whyNot => '¿Por qué no?';

  @override
  String get whyNotHint =>
      'Elige o escribe un motivo para guardar el día como “no fue nadie”.';

  @override
  String get writeYourOwn => '+ Escribe el tuyo';

  @override
  String get typeReasonHint => 'p. ej. Visita de la abuela';

  @override
  String get editEntry => 'Editar registro';

  @override
  String get changeReason => 'Cambiar motivo';

  @override
  String get deleteEntry => 'Eliminar registro';

  @override
  String get deleteEntryQuestion => '¿Eliminar registro?';

  @override
  String deleteEntryBody(String date) {
    return '$date: también se elimina en los dispositivos sincronizados.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get entryDeleted => 'Registro eliminado';

  @override
  String get undo => 'Deshacer';

  @override
  String get vacation => 'Vacaciones';

  @override
  String absentDidntGo(String names, String reasons) {
    return '$names no fue · $reasons';
  }

  @override
  String get selectWhoWent => 'Elige quién fue';

  @override
  String get editEntryTitle => 'Editar registro';

  @override
  String get whoWentQ => '¿Quién fue?';

  @override
  String get whenQ => '¿Cuándo?';

  @override
  String get howLongQ => '¿Cuánto tiempo?';

  @override
  String get whichKidsQ => '¿Qué niños?';

  @override
  String get activities => 'Actividades';

  @override
  String get addActivityEllipsis => 'Añadir actividad…';

  @override
  String get log => 'Registro';

  @override
  String get logEmpty =>
      'Aún no hay nada registrado. Las visitas que registres en Hoy aparecen aquí, de la más reciente a la más antigua.';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get thisYear => 'Este año';

  @override
  String playgroundVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'visitas al parque',
      one: 'visita al parque',
    );
    return '$_temp0';
  }

  @override
  String outsideAsFamily(String time) {
    return '$time al aire libre en familia';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get longestStreak => 'Racha más larga';

  @override
  String get topActivity => 'Actividad favorita';

  @override
  String get wentTheMost => 'Fue más veces';

  @override
  String kidOutsideMost(String name) {
    return '$name es quien más salió';
  }

  @override
  String get taglineLots => '¡Cuánto aire fresco! Bien hecho.';

  @override
  String taglineSolid(String period) {
    return '$period: mucho aire libre. ¡Sigue así!';
  }

  @override
  String get taglineEvery => 'Cada visita cuenta. Que vengan muchas más.';

  @override
  String recapEmpty(String period) {
    return 'Aún no hay nada registrado en $period';
  }

  @override
  String get recapEmptyHint => 'Registra una visita y aparecerá aquí.';

  @override
  String get allTime => 'Todo';

  @override
  String get customiseDashboard => 'Personalizar historial';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get year => 'Año';

  @override
  String get all => 'Todo';

  @override
  String get whoTookThem => 'Quién los llevó';

  @override
  String get nobodyLoggedYet => 'Aún no hay nadie registrado';

  @override
  String get kidsOutside => 'Niños al aire libre';

  @override
  String get noKidsLoggedYet => 'Aún no hay niños registrados';

  @override
  String get morningEvening => 'Mañana / tarde';

  @override
  String get noVisitsThisPeriod => 'Sin visitas en este periodo';

  @override
  String visitsInPeriod(String period) {
    return 'Visitas · $period';
  }

  @override
  String get outside => 'Al aire libre';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get oneSquarePerDayLower => 'un cuadrado por día';

  @override
  String get oneSquarePerMonthLower => 'un cuadrado por mes';

  @override
  String get legendBusy => 'Mucho';

  @override
  String get legendBoth => 'Ambos';

  @override
  String get legendSome => 'Algo';

  @override
  String get legendOne => 'Uno';

  @override
  String get legendNone => 'Nadie';

  @override
  String get mostPlayed => 'Lo más jugado';

  @override
  String get noActivitiesLoggedYet => 'Aún no hay actividades registradas';

  @override
  String get timeAndMissedDays => 'Tiempo y días sin salir';

  @override
  String get averageVisit => 'Visita media';

  @override
  String get whyNobodyWent => 'Por qué no fue nadie';

  @override
  String get noMissedDays => 'Ningún día sin salir en este periodo';

  @override
  String get noReasonsLoggedYet => 'Aún no hay motivos registrados';

  @override
  String get customiseDashboardTitle => 'Personalizar historial';

  @override
  String get reset => 'Restablecer';

  @override
  String get dragToReorder =>
      'Arrastra para reordenar  ·  activa para mostrar u ocultar';

  @override
  String get oneSquarePerDay => 'Un cuadrado por día';

  @override
  String onceOn(String date) {
    return 'Una vez · $date';
  }

  @override
  String get noDays => 'Sin días';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get weekdays => 'Entre semana';

  @override
  String get weekends => 'Fines de semana';

  @override
  String get addedToReminders => 'Añadido a Recordatorios';

  @override
  String get addedToCalendar => 'Añadido a tu calendario';

  @override
  String get remindersDenied =>
      'El acceso a Recordatorios está desactivado. Actívalo en Ajustes del iPhone.';

  @override
  String get calendarDenied =>
      'El acceso al Calendario está desactivado. Actívalo en Ajustes del iPhone.';

  @override
  String get planNoUpcomingDay =>
      'Este plan no tiene ningún día próximo que añadir';

  @override
  String get remindersUnavailable =>
      'Recordatorios solo está disponible en el iPhone';

  @override
  String get calendarUnavailable =>
      'Calendario solo está disponible en el iPhone';

  @override
  String get remindersError => 'No se pudo añadir a Recordatorios';

  @override
  String get calendarError => 'No se pudo añadir al Calendario';

  @override
  String withKids(String names) {
    return 'Con $names';
  }

  @override
  String get editPlan => 'Editar plan';

  @override
  String get addToCalendar => 'Añadir al Calendario';

  @override
  String get addToCalendarSub =>
      'Abre el Calendario del iPhone: añade invitados allí';

  @override
  String get addToReminders => 'Añadir a Recordatorios';

  @override
  String get addToRemindersSub =>
      'Un recordatorio con aviso a la hora del plan';

  @override
  String get todayNotDoneYet => 'Hoy · aún sin hacer';

  @override
  String get planNoDaysYet =>
      'Aún no hay días. Aparecerán aquí cuando empiece el plan.';

  @override
  String get deletePlanQuestion => '¿Eliminar plan?';

  @override
  String deletePlanBody(String title) {
    return '“$title” y todo su historial se eliminarán para siempre.';
  }

  @override
  String get newPlan => 'Nuevo plan';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String reminderAt(String time) {
    return 'Aviso $time';
  }

  @override
  String get tapForHistory =>
      'Toca para ver historial, Calendario y Recordatorios';

  @override
  String get deactivate => 'Desactivar';

  @override
  String get activate => 'Activar';

  @override
  String get noPlansYet => 'Aún no hay planes';

  @override
  String get noPlansHint =>
      'Añade planes que se repiten ciertos días o que pasan una sola vez.\nAparecen en Hoy.';

  @override
  String get addFirstPlan => 'Añadir el primer plan';

  @override
  String get enterTitle => 'Escribe un título';

  @override
  String get pickADate => 'Elige una fecha';

  @override
  String get selectAtLeastOneDay => 'Elige al menos un día';

  @override
  String get notSet => 'Sin fecha';

  @override
  String get planTitle => 'Título';

  @override
  String get planTitleHint => 'p. ej. Fútbol';

  @override
  String get howOftenQ => '¿Con qué frecuencia?';

  @override
  String get repeats => 'Se repite';

  @override
  String get oneTime => 'Una vez';

  @override
  String dateLabel(String date) {
    return 'Fecha: $date';
  }

  @override
  String get repeatOn => 'Se repite el';

  @override
  String get dateRangeOptional => 'Periodo (opcional)';

  @override
  String fromDate(String date) {
    return 'Desde: $date';
  }

  @override
  String toDate(String date) {
    return 'Hasta: $date';
  }

  @override
  String get clearDates => 'Borrar fechas';

  @override
  String get reminderNotification => 'Notificación de aviso';

  @override
  String get reminderNotificationSub =>
      'Envía una notificación los días del plan';

  @override
  String notifyAt(String time) {
    return 'Avisar a las  $time';
  }

  @override
  String get customMessageHint =>
      'Mensaje propio (opcional)\np. ej. ¡Hora de salir!';

  @override
  String get leaveEmptyDefault => 'Déjalo vacío para usar el mensaje estándar.';

  @override
  String get timeAlreadyPassed =>
      'Esta hora ya ha pasado, así que no llegará ningún aviso. Elige una hora más tarde.';

  @override
  String get alsoAddTo => 'Añadir también a (opcional)';

  @override
  String get calendar => 'Calendario';

  @override
  String get remindersApp => 'Recordatorios';

  @override
  String get alsoAddToHint =>
      'Al guardar: el Calendario se abre con el plan ya rellenado, para que puedas invitar a gente. Recordatorios recibe el plan con un aviso a su hora.';

  @override
  String get inactivePlansHidden => 'Los planes inactivos no aparecen en Hoy';

  @override
  String get themeModernistLight => 'Modernista claro';

  @override
  String get themeModernistLightSub => 'Rojo y negro sobre papel, el original';

  @override
  String get themeModernistDark => 'Modernista oscuro';

  @override
  String get themeModernistDarkSub => 'Coral sobre negro cálido';

  @override
  String get themeSwingLight => 'Swing claro';

  @override
  String get themeSwingLightSub => 'Verde intenso y naranja sobre amarillo sol';

  @override
  String get themeSwingDark => 'Swing oscuro';

  @override
  String get themeSwingDarkSub => 'Amarillo sol sobre verde intenso';

  @override
  String get themeBlackOnWhite => 'Negro sobre blanco';

  @override
  String get themeBlackOnWhiteSub => 'Negro sencillo sobre blanco';

  @override
  String get themeWhiteOnBlack => 'Blanco sobre negro';

  @override
  String get themeWhiteOnBlackSub => 'Blanco sencillo sobre negro';

  @override
  String get themeMyColors => 'Mis colores';

  @override
  String get themeMyColorsSub => 'Tu propio fondo, texto y color de acento';

  @override
  String get family => 'Familia';

  @override
  String get parentsAndKids => 'Padres y niños';

  @override
  String get familySync => 'Sincronizar en familia';

  @override
  String get familySyncSub => 'Compartir entre Apple ID';

  @override
  String get app => 'App';

  @override
  String get remindersSetting => 'Avisos';

  @override
  String get languageDateTheme => 'Idioma, fecha y tema';

  @override
  String get privacy => 'Privacidad';

  @override
  String get noDataCollected => 'No se recopilan datos';

  @override
  String get yourData => 'Tus datos';

  @override
  String get logSub => 'Todas las visitas, la más reciente primero';

  @override
  String get deleteAllData => 'Eliminar todos los datos';

  @override
  String get deleteAllDataSub => 'En este iPhone y en iCloud';

  @override
  String get aboutNote =>
      'Playground Tracker es una compra única en el App Store. Sin suscripción, sin cuenta, sin anuncios. Tu registro se queda en tus dispositivos y se sincroniza con tu propio iCloud.';

  @override
  String get deleteAllDataQuestion => '¿Eliminar todos los datos?';

  @override
  String get deleteAllDataBody =>
      'Todas las visitas, planes, nombres y ajustes se eliminan de este iPhone y de tu iCloud. Si compartes el registro con tu familia, ellos también lo pierden. No se puede deshacer.';

  @override
  String get deleteEverything => 'Eliminarlo todo';

  @override
  String get deleting => 'Eliminando…';

  @override
  String get nothingDeleted => 'No se ha eliminado nada';

  @override
  String get nothingDeletedBody =>
      'No se pudo conectar con iCloud, así que tus datos se han quedado como estaban (si no, la sincronización los volvería a traer). Inténtalo de nuevo cuando tengas conexión.';

  @override
  String get ok => 'OK';

  @override
  String get notificationsTitle => 'Avisos';

  @override
  String get outdoorReminder => 'Aviso para salir';

  @override
  String get outdoorReminderSub =>
      '¿Has sacado hoy a los niños? Llega una vez al día, a la hora que elijas.';

  @override
  String get logReminder => 'Aviso para registrar';

  @override
  String get logReminderSub =>
      'No olvides registrar la visita al parque de hoy. Llega una vez al día, a la hora que elijas.';

  @override
  String everyDayAt(String time) {
    return 'Todos los días a las  $time';
  }

  @override
  String get notificationsBlocked =>
      'Las notificaciones están bloqueadas. Abre Ajustes › Playground Tracker › Notificaciones y permítelas.';

  @override
  String get retry => 'Reintentar';

  @override
  String get notificationsLocalNote =>
      'Las notificaciones son locales, no hace falta internet. Cada persona de la familia elige sus propias horas en su propio teléfono.';

  @override
  String get language => 'Idioma';

  @override
  String get phoneLanguage => 'Idioma del teléfono';

  @override
  String get colorTheme => 'Tema de color';

  @override
  String get editMyColors => 'Editar mis colores';

  @override
  String get timeFormat => 'Formato de hora';

  @override
  String get hour12 => '12 horas';

  @override
  String get hour24 => '24 horas';

  @override
  String get changesApplyImmediately =>
      'Los cambios se aplican al instante en toda la app.';

  @override
  String contrastTextWarning(String ratio) {
    return 'El texto se lee mal sobre este fondo: contraste $ratio:1, procura 4,5:1 o más.';
  }

  @override
  String contrastAccentWarning(String ratio) {
    return 'El acento se ve mal sobre este fondo: contraste $ratio:1, procura 3:1 o más.';
  }

  @override
  String get sampleMom => 'Mamá';

  @override
  String get sampleDad => 'Papá';

  @override
  String get colorBackground => 'Fondo';

  @override
  String get colorText => 'Texto';

  @override
  String get colorAccent => 'Acento (botones, selecciones)';

  @override
  String get notifOutdoorTitle => 'Aviso del parque';

  @override
  String get notifOutdoorBody => '¿Has sacado hoy a los niños?';

  @override
  String get notifLogTitle => 'Registra el tiempo al aire libre';

  @override
  String get notifLogBody => 'No olvides registrar la visita al parque de hoy.';

  @override
  String get notifPlanDefaultBody => 'Es la hora de tu plan';

  @override
  String get addParentAndKid => 'Añade al menos un padre o madre y un niño';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get familyEditIntro =>
      'Actualiza los miembros de tu familia. Los registros existentes no cambian.';

  @override
  String get familySetupIntro =>
      'Vamos a configurar tu familia. Siempre puedes añadir más personas después.';

  @override
  String get parentsGrandparents => 'Padres / abuelos';

  @override
  String get parentHint1 => 'p. ej. Mamá';

  @override
  String get parentHint2 => 'p. ej. Papá';

  @override
  String get parentHintMore => 'Padre, madre o abuelo';

  @override
  String get addParent => '+ Añadir adulto';

  @override
  String get kidHint1 => 'p. ej. Lucía';

  @override
  String get kidHint2 => 'p. ej. Mateo';

  @override
  String get kidHintMore => 'Nombre del niño';

  @override
  String get addKid => '+ Añadir niño';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get saveAndStart => 'Guardar y empezar';

  @override
  String minutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'hace $count h';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get removeAccessQuestion => '¿Quitar el acceso?';

  @override
  String removeAccessBody(String name) {
    return '$name dejará de sincronizar con este registro. Sus registros existentes se quedan en su teléfono.';
  }

  @override
  String get remove => 'Quitar';

  @override
  String get couldNotRemove => 'No se pudo quitar. Inténtalo de nuevo.';

  @override
  String get connectedUser => 'Usuario conectado';

  @override
  String get inviteSomeone => 'Invitar a alguien';

  @override
  String get inviteSub =>
      'Abre el menú Compartir de iOS: envía por Mensajes, WhatsApp o copia el enlace';

  @override
  String get connected => 'Conectado';

  @override
  String lastSynced(String time) {
    return 'Última sincronización $time';
  }

  @override
  String get shareWithFamily => 'Comparte con tu familia';

  @override
  String get shareWithFamilySub =>
      'Cada persona usa su propio Apple ID. No hace falta compartir cuentas.';

  @override
  String get owner => 'Propietario';

  @override
  String get invitePending => 'Invitación pendiente…';

  @override
  String get you => 'Tú';

  @override
  String get noOneConnected => 'Aún no hay nadie conectado';

  @override
  String get noOneConnectedHint =>
      'Toca “Invitar a alguien” arriba para compartir\ncon tu pareja o tu familia.';

  @override
  String get howItWorks => 'Cómo funciona';

  @override
  String get howStep1 =>
      'Toca “Invitar a alguien” y se abre el menú Compartir de iOS';

  @override
  String get howStep2 => 'Envía el enlace por Mensajes, WhatsApp o cópialo';

  @override
  String get howStep3 => 'Tocan el enlace y luego “Aceptar”. Listo.';

  @override
  String get howStep4 => 'Los dos teléfonos se sincronizan solos';

  @override
  String get onbParentsTitle => '¿Quién saca a los niños?';

  @override
  String get onbParentsNote =>
      'No hacen falta nombres reales: Mamá y Papá, apodos o iniciales sirven igual. Los nombres solo aparecen en la app.';

  @override
  String get onbKidsTitle => '¿Y los niños?';

  @override
  String get onbKidHint1 => 'p. ej. Frijolito';

  @override
  String get onbKidHint2 => 'p. ej. Tigre';

  @override
  String get onbKidsNote =>
      'Aquí los apodos también son perfectos. Todo se queda en tu iPhone y en tu propio iCloud, nunca con nosotros.';

  @override
  String get getStarted => 'Empezar';

  @override
  String get startUsingApp => 'Empezar a usar la app';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get back => 'Atrás';

  @override
  String get onbWelcome1 =>
      'Un registro rápido del tiempo al aire libre de tu familia: quién sacó a los niños, cuánto tiempo y qué hicieron.';

  @override
  String get onbWelcome2 =>
      'Los siguientes pasos configuran tu familia, avisos opcionales y planes. Lleva un minuto y todo se puede cambiar después en Ajustes.';

  @override
  String get onbWelcomeNote =>
      'Sin cuenta, sin anuncios, sin rastreo. Tu registro se queda en tu iPhone y en tu propio iCloud.';

  @override
  String get name => 'Nombre';

  @override
  String get addAnotherChip => '+ Añadir otro';

  @override
  String get onbRemindersIntro =>
      'Opcional. Un pequeño aviso una vez al día, a la hora que elijas. iOS pide permiso cuando activas uno.';

  @override
  String get onbReminderOutside => 'Hora de salir';

  @override
  String get onbReminderLog => 'Registrar la visita de hoy';

  @override
  String get onbRemindersLater =>
      'Puedes cambiarlos cuando quieras en Ajustes › Avisos.';

  @override
  String everyDayAtChange(String time) {
    return 'Todos los días a las $time · cambiar';
  }

  @override
  String get onbPlansIntro =>
      'Opcional. Fútbol cada lunes, natación los sábados, un cumpleaños la semana que viene: los planes aparecen en Hoy, listos para marcarlos, y te pueden avisar.';

  @override
  String get addAPlan => 'Añadir un plan';

  @override
  String get addAnotherPlan => 'Añadir otro plan';

  @override
  String get onbPlansLater =>
      'Puedes añadir más cuando quieras en la pestaña Planes.';

  @override
  String get onbLookTitle => 'Tu estilo';

  @override
  String get onbLookIntro =>
      'Elige un tema de color o crea el tuyo. Puedes cambiarlo cuando quieras en Ajustes.';

  @override
  String get privInShortTitle => 'En resumen';

  @override
  String get privInShort =>
      'Playground Tracker no recopila datos personales. No hay cuenta, ni servidor nuestro, ni analíticas, ni publicidad, ni rastreo. El desarrollador no puede ver tu registro.';

  @override
  String get privStoresTitle => 'Qué guarda la app';

  @override
  String get privStores =>
      'Los nombres de los padres y niños que introduces, tus visitas (fecha, mañana o tarde, quién fue, qué niños, cuánto tiempo, actividades y cualquier motivo que indiques), tus planes y cómo fueron, y tus ajustes. Todo se guarda en el almacenamiento privado de la app en tu iPhone.';

  @override
  String get privICloudTitle => 'Sincronización con iCloud y familia';

  @override
  String get privICloud =>
      'Si has iniciado sesión en iCloud, la app guarda una copia en tu propia base de datos privada de iCloud mediante CloudKit de Apple, para que esté sincronizada entre tus dispositivos. Si invitas a familiares con un enlace, las personas invitadas pueden ver y editar el registro compartido hasta que dejes de compartirlo. Apple gestiona los datos de iCloud según su política de privacidad; el desarrollador no tiene acceso a ellos.';

  @override
  String get privRemindersTitle => 'Avisos';

  @override
  String get privReminders =>
      'Las notificaciones de aviso se programan en tu iPhone. No se envía nada sobre ellas a ningún sitio. La app solo pide permiso cuando activas un aviso.';

  @override
  String get privCalendarTitle => 'Calendario y Recordatorios';

  @override
  String get privCalendar =>
      'Añadir al Calendario abre el editor de eventos de Apple con el plan ya rellenado. La app no lee tu calendario; el evento solo se guarda si tocas Añadir. Añadir a Recordatorios guarda el plan como un recordatorio nuevo en tu app Recordatorios. La app no lee tus recordatorios y no se envía nada a ningún sitio.';

  @override
  String get privChildrenTitle => 'Niños';

  @override
  String get privChildren =>
      'La app está pensada para padres. Los nombres de los niños se quedan en tu iPhone y en tu propio iCloud. No se envía nada sobre los niños al desarrollador ni a nadie más.';

  @override
  String get privDeletingTitle => 'Eliminar tus datos';

  @override
  String get privDeleting =>
      'Ajustes › Eliminar todos los datos borra todo de una vez, de tu iPhone y de tu iCloud; si compartes el registro con tu familia, también se borra para ellos. También puedes eliminar registros sueltos en cualquier momento, y al eliminar la app se borra todo lo guardado en el iPhone. Para dejar de compartir, usa Sincronizar en familia en Ajustes.';

  @override
  String get privChangesTitle => 'Cambios';

  @override
  String get privChanges =>
      'Si esta política cambia, la nueva versión llega con una actualización de la app y su fecha de entrada en vigor cambia arriba.';

  @override
  String privacyEffective(String date) {
    return 'En vigor desde el $date';
  }

  @override
  String get dashTapToChange => '— toca para cambiar';

  @override
  String get hour24Time => 'Formato de 24 horas';

  @override
  String get justNow => 'ahora mismo';

  @override
  String parentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adultos',
      one: '1 adulto',
    );
    return '$_temp0';
  }

  @override
  String kidsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count niños',
      one: '1 niño',
    );
    return '$_temp0';
  }

  @override
  String personRemoved(String name) {
    return '$name quitado';
  }

  @override
  String get advanced => 'Avanzado';

  @override
  String get startTime => 'Inicio';

  @override
  String get endTime => 'Fin';

  @override
  String get endAfterStart => 'El fin tiene que ser después del inicio';

  @override
  String timeOutside(String time) {
    return '$time al aire libre';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días de racha',
      one: 'día de racha',
    );
    return '$_temp0';
  }

  @override
  String get streakDoneToday => 'Hecho por hoy';

  @override
  String get streakKeepGoing => 'Sal hoy para seguir la racha';

  @override
  String get streakAtRisk => 'Ayer no hubo salida. Sal hoy para no perderla';

  @override
  String get streakStart => 'Sal hoy para empezar una';

  @override
  String get streakRule =>
      'La racha cuenta los días que saliste. Se perdona un día sin salir; dos seguidos la terminan. Las vacaciones la pausan.';

  @override
  String get goal => 'Meta';

  @override
  String get setAGoal => 'Fija una meta al aire libre';

  @override
  String goalOf(String done, String target) {
    return '$done de $target';
  }

  @override
  String get goalReached => 'Meta cumplida';

  @override
  String get outdoorGoal => 'Meta al aire libre';

  @override
  String get goalPeriod => 'Periodo';

  @override
  String get hoursOutside => 'Horas al aire libre';

  @override
  String get otherAmount => 'Otro';

  @override
  String get hoursHint => 'Horas, p. ej. 12';

  @override
  String get goalNote =>
      'Cuenta la duración de cada visita que registras. Una meta popular es 1000 horas al año: unas 2 horas y 45 minutos al día.';

  @override
  String get turnOffGoal => 'Quitar la meta';

  @override
  String get goalOff => 'Desactivada';

  @override
  String goalAWeek(String time) {
    return '$time a la semana';
  }

  @override
  String goalAMonth(String time) {
    return '$time al mes';
  }

  @override
  String goalAYear(String time) {
    return '$time al año';
  }

  @override
  String get outdoorActivity => 'Actividad al aire libre';

  @override
  String get outdoorActivitySub =>
      'Al marcarla como hecha cuenta como tiempo al aire libre. Desactívalo para cosas como clases de piano.';

  @override
  String goalToGo(String time) {
    return 'Faltan $time';
  }
}
