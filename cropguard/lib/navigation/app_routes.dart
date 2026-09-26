class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // Pestañas de la barra inferior
  static const home = '/home';
  static const history = '/history';
  static const crops = '/crops';
  static const profile = '/profile';

  // Pantallas a pantalla completa (sin barra inferior)
  static const diagnose = '/diagnose';
  static const recommendations = '/recommendations';
  static const notifications = '/notifications';
  static const help = '/help';

  // Detalle de un cultivo específico
  static const cropDetail = '/crops/:cropId';
  static String cropDetailPath(String cropId) => '/crops/$cropId';

  static const diagnosisDetail = '/history/:diagnosisId';
  static String diagnosisDetailPath(String diagnosisId) =>
      '/history/$diagnosisId';
}
