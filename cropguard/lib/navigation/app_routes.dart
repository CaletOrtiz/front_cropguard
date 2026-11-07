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
  static const farmCropDetail = '/farms/:farmId/crops/:cropId';
  static String farmCropDetailPath(String farmId, String cropId) =>
      '/farms/$farmId/crops/$cropId';
  static const farmCropEdit = '/farms/:farmId/crops/:cropId/edit';
  static String farmCropEditPath(String farmId, String cropId) =>
      '/farms/$farmId/crops/$cropId/edit';
  static const farmPlotNew = '/farms/:farmId/crops/:cropId/plots/new';
  static String farmPlotNewPath(String farmId, String cropId) =>
      '/farms/$farmId/crops/$cropId/plots/new';
  static const farmPlotDetail = '/farms/:farmId/crops/:cropId/plots/:plotId';
  static String farmPlotDetailPath(
    String farmId,
    String cropId,
    String plotId,
  ) => '/farms/$farmId/crops/$cropId/plots/$plotId';
  static const farmPlotEdit = '/farms/:farmId/crops/:cropId/plots/:plotId/edit';
  static String farmPlotEditPath(String farmId, String cropId, String plotId) =>
      '/farms/$farmId/crops/$cropId/plots/$plotId/edit';
  static const cropNew = '/crops/new';
  static const cropDetail = '/crops/:cropId';
  static String cropDetailPath(String id) => '/crops/$id';

  static const plotNew = '/crops/:cropId/plots/new';
  static String plotNewPath(String cropId) => '/crops/$cropId/plots/new';

  static const plotDetail = '/plots/:plotId';
  static String plotDetailPath(String id) => '/plots/$id';
  static const plotOverview = '/plots';
  static const plotAlerts = '/plots/alerts';
  static const plotDanger = '/plots/danger';

  static const sampling = '/plots/:plotId/sampling';
  static String samplingPath(String id) => '/plots/$id/sampling';
  static const careList = '/plots/:plotId/care';
  static String careListPath(String id) => '/plots/$id/care';
  static const careNew = '/plots/:plotId/care/new';
  static String careNewPath(String id) => '/plots/$id/care/new';
  static const careEdit = '/plots/:plotId/care/:activityId/edit';
  static String careEditPath(String plotId, String id) =>
      '/plots/$plotId/care/$id/edit';
  static const careDetail = '/plots/:plotId/care/:activityId';
  static String careDetailPath(String plotId, String id) =>
      '/plots/$plotId/care/$id';
  static const plotStats = '/plots/:plotId/stats';
  static String plotStatsPath(String id) => '/plots/$id/stats';
  static const plotTimeline = '/plots/:plotId/timeline';
  static String plotTimelinePath(String id) => '/plots/$id/timeline';
  static const harvests = '/plots/:plotId/harvests';
  static String harvestsPath(String id) => '/plots/$id/harvests';
  static const harvestNew = '/plots/:plotId/harvests/new';
  static String harvestNewPath(String id) => '/plots/$id/harvests/new';
  static const harvestDetail = '/plots/:plotId/harvests/:harvestId';
  static String harvestDetailPath(String plotId, String id) =>
      '/plots/$plotId/harvests/$id';
  static const loss = '/plots/:plotId/loss';
  static String lossPath(String id) => '/plots/$id/loss';
  static const lossNew = '/plots/:plotId/loss/new';
  static String lossNewPath(String id) => '/plots/$id/loss/new';
  static const lossDetail = '/plots/:plotId/loss/:estimationId';
  static String lossDetailPath(String plotId, String id) =>
      '/plots/$plotId/loss/$id';
  static const reports = '/plots/:plotId/reports';
  static String reportsPath(String id) => '/plots/$id/reports';
  static const reportNew = '/plots/:plotId/reports/new';
  static String reportNewPath(String id) => '/plots/$id/reports/new';

  // Guía estática (antes /crops)
  static const guide = '/guide';
  static const guideDetail = '/guide/:cropId';
  static String guideDetailPath(String id) => '/guide/$id';

  // Detalle de un diagnóstico del historial
  static const diagnosisDetail = '/history/:diagnosisId';
  static String diagnosisDetailPath(String id) => '/history/$id';
}
