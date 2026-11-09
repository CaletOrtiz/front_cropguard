class PlanCatalog {
  PlanCatalog._();

  static const freeFarmLimit = 1;
  static const freeCropLimit = 2;
  static const freePlotLimit = 5;
  static const freeMonthlyDiagnosisLimit = 3;
  static const premiumMonthlyDiagnosisLimit = 30;
  static const premiumPriceInCop = 19900;
  static const premiumDurationDays = 30;

  static const freeBenefits = <String>[
    '$freeFarmLimit finca registrada',
    'Hasta $freeCropLimit cultivos',
    'Hasta $freePlotLimit lotes',
    'Registro y consulta de muestreos',
    'Hasta $freeMonthlyDiagnosisLimit diagnósticos con IA al mes',
    'Registro de cosechas',
    'Registro de actividades de cuidado',
    'Consulta del estado general de la finca',
    'Historial básico',
  ];

  static const premiumBenefits = <String>[
    'Fincas, cultivos y lotes ilimitados',
    'Hasta $premiumMonthlyDiagnosisLimit diagnósticos con IA al mes',
    'Historial completo de diagnósticos',
    'Estadísticas y análisis de cultivos y lotes',
    'Estimaciones de pérdidas agrícolas',
    'Informes detallados por lote en PDF',
    'Seguimiento de actividades de cuidado',
    'Historial de cosechas y evolución de los cultivos',
    'Acceso a las funcionalidades de análisis disponibles en Kroppi',
  ];
}
