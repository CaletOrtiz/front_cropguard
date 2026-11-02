class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // Pestañas de la barra inferior
  static const home = '/home';
  static const history = '/history';
  static const farms = '/farms';
  static const crops = '/crops';
  static const profile = '/profile';

  // Pantallas a pantalla completa
  static const diagnose = '/diagnose';
  static const notifications = '/notifications';
  static const help = '/help';
  static const personalData = '/profile/personal-data';

  // Cultivos y lotes del usuario (cropNew SIEMPRE antes de cropDetail)
  static const farmNew = '/farms/new';
  static const farmDetail = '/farms/:farmId';
  static String farmDetailPath(String id) => '/farms/$id';
  static const farmEdit = '/farms/:farmId/edit';
  static String farmEditPath(String id) => '/farms/$id/edit';
  static const farmCropNew = '/farms/:farmId/crops/new';
  static String farmCropNewPath(String id) => '/farms/$id/crops/new';
  static const farmCropEdit = '/farms/:farmId/crops/:cropId/edit';
  static String farmCropEditPath(String farmId, String cropId) =>
      '/farms/$farmId/crops/$cropId/edit';
  static const farmPlotNew = '/farms/:farmId/crops/:cropId/plots/new';
  static String farmPlotNewPath(String farmId, String cropId) =>
      '/farms/$farmId/crops/$cropId/plots/new';
  static const farmPlotDetail =
      '/farms/:farmId/crops/:cropId/plots/:plotId';
  static String farmPlotDetailPath(String farmId, String cropId, String plotId) =>
      '/farms/$farmId/crops/$cropId/plots/$plotId';
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
