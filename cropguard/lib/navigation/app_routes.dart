class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // Pestañas de la barra inferior
  static const home = '/home';
  static const history = '/history';
  static const crops = '/crops'; // Mis cultivos
  static const profile = '/profile';

  // Pantallas a pantalla completa
  static const diagnose = '/diagnose';
  static const notifications = '/notifications';
  static const help = '/help';
  static const personalData = '/profile/personal-data';

  // Cultivos y lotes del usuario (cropNew SIEMPRE antes de cropDetail)
  static const cropNew = '/crops/new';
  static const cropDetail = '/crops/:cropId';
  static String cropDetailPath(String id) => '/crops/$id';

  static const plotNew = '/crops/:cropId/plots/new';
  static String plotNewPath(String cropId) => '/crops/$cropId/plots/new';

  static const plotDetail = '/plots/:plotId';
  static String plotDetailPath(String id) => '/plots/$id';

  static const sampling = '/plots/:plotId/sampling';
  static String samplingPath(String id) => '/plots/$id/sampling';

  // Guía estática (antes /crops)
  static const guide = '/guide';
  static const guideDetail = '/guide/:cropId';
  static String guideDetailPath(String id) => '/guide/$id';

  // Detalle de un diagnóstico del historial
  static const diagnosisDetail = '/history/:diagnosisId';
  static String diagnosisDetailPath(String id) => '/history/$id';
}
