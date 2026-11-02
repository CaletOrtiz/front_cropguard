class AppStrings {
  AppStrings._();

  // General
  static const appName = 'Kroppi';
  static const slogan = 'Tecnología que cuida el campo';
  static const tagline = 'Detecta • Previene • Protege';
  static const start = 'Comenzar';
  static const poweredByAi = 'Impulsado por inteligencia artificial';
  static const detect = 'Detecta';
  static const prevent = 'Previene';
  static const protect = 'Protege';

  // Autenticación
  static const fullName = 'Nombre completo';
  static const email = 'Correo electrónico';
  static const password = 'Contraseña';
  static const register = 'Registrarse';
  static const login = 'Iniciar sesión';
  static const continueGoogle = 'Continuar con Google';
  static const continueApple = 'Continuar con Apple';
  static const welcomeBack = 'Bienvenido de vuelta';
  static const loginSubtitle = 'Ingresa para continuar';
  static const createAccount = 'Crea tu cuenta';
  static const registerSubtitle =
      'Únete a la comunidad de agricultores inteligentes';
  static const noAccount = '¿No tienes cuenta?';
  static const signUpLink = 'Regístrate';
  static const haveAccount = '¿Ya tienes cuenta?';
  static const signInLink = 'Inicia sesión';
  static const orContinueWith = 'O continúa con';

  // Navegación
  static const navHome = 'Inicio';
  static const navHistory = 'Historial';
  static const navFarms = 'Fincas';
  static const navProfile = 'Perfil';

  // Dashboard
  static const greeting = 'Hola,';
  static const whatToday = '¿Qué deseas hacer hoy?';
  static const diagnoseDisease = 'Diagnosticar enfermedad';
  static const diagnoseHint =
      'Toma una foto de la hoja y deja que la IA haga el análisis.';
  static const quickAccess = 'Accesos rápidos';
  static const myDiagnoses = 'Mis diagnósticos';
  static const cropGuide = 'Guía de cultivos';
  static const profile = 'Perfil';
  static const homeSummary = 'Resumen';
  static const farms = 'Fincas';
  static const plots = 'Lotes';
  static const crops = 'Cultivos';
  static const alertPlots = 'En alerta';
  static const dangerPlots = 'En peligro';
  static const pendingMonitoring = 'Pendientes de monitoreo';
  static const myFarms = 'Mis fincas';
  static const createFarm = 'Crear finca';
  static const createFirstFarm = 'Crea tu primera finca';
  static const noFarmsTitle = 'Aún no tienes fincas';
  static const noFarmsSubtitle =
      'Registra tu primera finca para empezar a monitorear tus cultivos.';
  static const startSampling = 'Iniciar muestreo';
  static const neverSampled = 'Nunca se ha muestreado';
  static const reports = 'Informes';
  static const reportsHint = 'Consulta tus diagnósticos guardados';

  static String daysSinceSample(int days) =>
      'Último muestreo hace $days ${days == 1 ? 'día' : 'días'}';

  // Diagnóstico
  static const takePhotoHint = 'Toma una foto clara de la hoja afectada.';
  static const aiWillAnalyze = 'La IA analizará la imagen en segundos.';
  static const gallery = 'Galería';
  static const analyzing = 'Analizando imagen…';
  static const analyzingHint =
      'Identificando patrones morfológicos de la hoja.';
  static const cnnNote = 'Modelo de visión computacional (CNN)';

  // Historial
  static const historyTitle = 'Historial de diagnósticos';
  static const searchHint = 'Buscar por patógeno o cultivo';
  static const filterAll = 'Todos';
  static const emptyHistoryTitle = 'Aún no tienes diagnósticos';
  static const emptyHistorySubtitle =
      'Los análisis que guardes aparecerán aquí.';

  // Cultivos
  static const cropsTitle = 'Guía de cultivos';
  static const cropsSubtitle =
      'Aprende a identificar y prevenir enfermedades comunes.';
  static const commonDiseases = 'Enfermedades comunes';
  static const characteristicSymptoms = 'Síntomas característicos';
  static const monitoringTipsTitle = 'Consejos de monitoreo';
  static const preventionTipsTitle = 'Recomendaciones preventivas';

  // Recomendaciones
  static const recommendationsTitle = 'Recomendaciones';

  // Perfil
  static const profileTitle = 'Perfil';
  static const notificationsMenu = 'Notificaciones';
  static const helpSupport = 'Ayuda y soporte';
  static const logout = 'Cerrar sesión';
  static const logoutConfirmTitle = '¿Cerrar sesión?';
  static const logoutConfirmMessage =
      'Tendrás que iniciar sesión de nuevo para usar Kroppi.';
  static const cancel = 'Cancelar';

  // Resultado / detalle de diagnóstico
  static const possiblePathogen = 'Posible patógeno';
  static const symptomsObserved = 'Síntomas observados';
  static const diagnosisDisclaimer =
      'Resultado preliminar basado en análisis visual. Para confirmación definitiva consulte un especialista o realice análisis de laboratorio.';

  static const seeAll = 'Ver todos';
  static const myDiagnosesHint = 'Revisa tus análisis anteriores';
  static const cropGuideHint = 'Aprende sobre tus cultivos';
  static const profileHint = 'Gestiona tu cuenta y datos';

  static const searchCropHint = 'Buscar cultivo...';
  static const noCropsFound = 'No encontramos cultivos con ese nombre.';
}
