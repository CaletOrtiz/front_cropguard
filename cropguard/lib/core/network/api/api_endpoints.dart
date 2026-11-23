/// Define los endpoints y la URL base para conectar con FastAPI.
class ApiEndpoints {
  ApiEndpoints._();

  /// URL base del backend FastAPI desplegado en Render.
  static const String defaultBaseUrl = 'https://backend-ai-kroppi.onrender.com';

  /// **GET /health** (Público)
  /// Estado de la API y versión del modelo de IA.
  static const String health = '/health';

  /// **POST /diagnoses** (Requiere token)
  /// Recibe una imagen y crea un diagnóstico ejecutando el pipeline de IA.
  ///
  /// **GET /diagnoses** (Requiere token)
  /// Lista los diagnósticos del usuario autenticado (soporta `limit` y `offset`).
  static const String diagnoses = '/diagnoses';
  static const String createPayment = '/payments/create';

  /// **GET /diagnoses/{diagnostico_id}** (Requiere token)
  /// Obtiene un diagnóstico propio por su UUID.
  static String diagnosisById(String diagnosticoId) =>
      '/diagnoses/$diagnosticoId';

  static String careActivities(String plotId) =>
      '/plots/$plotId/care-activities';
  static String careActivity(String activityId) =>
      '/care-activities/$activityId';
  static String careEvidence(String activityId) =>
      '/care-activities/$activityId/evidence';
  static String plotStats(String plotId) => '/plots/$plotId/stats';
  static String plotTimeline(String plotId) => '/plots/$plotId/timeline';
  static String plotReportData(String plotId) => '/plots/$plotId/report-data';
  static String plotReports(String plotId) => '/plots/$plotId/reports';
  static String report(String reportId) => '/reports/$reportId';

  static String plotHarvests(String plotId) => '/plots/$plotId/harvests';
  static String harvest(String id) => '/harvests/$id';
  static String plotLossEstimations(String plotId) =>
      '/plots/$plotId/loss-estimations';
  static String plotLossDefaults(String plotId) =>
      '/plots/$plotId/loss-estimations/defaults';
  static String plotLossPreview(String plotId) =>
      '/plots/$plotId/loss-estimations/preview';
  static String lossEstimation(String id) => '/loss-estimations/$id';
}
