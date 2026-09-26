class DiagnosisRecord {
  const DiagnosisRecord({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.pathogen,
    required this.pathogenType,
    required this.date,
    required this.confidence,
    required this.symptoms,
    required this.recommendations,
  });

  final String id;
  final String cropId;
  final String cropName;
  final String pathogen;
  final String pathogenType; // Hongo, Oomiceto, Bacteria
  final DateTime date;
  final int confidence; // 0-100
  final List<String> symptoms;
  final List<String> recommendations;
}

/// Datos de ejemplo para construir la vista.
/// TODO: reemplazar por diagnósticos reales (almacenamiento local o API).
class SampleDiagnoses {
  SampleDiagnoses._();

  static final List<DiagnosisRecord> all = [
    DiagnosisRecord(
      id: '1',
      cropId: 'tomate',
      cropName: 'Tomate',
      pathogen: 'Alternaria solani',
      pathogenType: 'Hongo',
      date: DateTime(2026, 9, 20),
      confidence: 92,
      symptoms: [
        'Manchas necróticas en forma de ojo.',
        'Halo clorótico alrededor de las manchas.',
        'Amarillamiento progresivo de la hoja.',
      ],
      recommendations: [
        'Aplicar fungicida específico, sujeto a confirmación.',
        'Mejorar la ventilación del cultivo.',
        'Eliminar hojas muy afectadas.',
      ],
    ),
    DiagnosisRecord(
      id: '2',
      cropId: 'papa',
      cropName: 'Papa',
      pathogen: 'Phytophthora infestans',
      pathogenType: 'Oomiceto',
      date: DateTime(2026, 9, 15),
      confidence: 78,
      symptoms: [
        'Lesiones húmedas de color pardo en hojas y tallos.',
        'Halo clorótico en el borde de las manchas.',
      ],
      recommendations: [
        'Mejorar el drenaje del terreno.',
        'Evitar riego por aspersión sobre el follaje.',
        'Monitorear la evolución de los síntomas.',
      ],
    ),
    DiagnosisRecord(
      id: '3',
      cropId: 'cafe',
      cropName: 'Café',
      pathogen: 'Hemileia vastatrix',
      pathogenType: 'Hongo',
      date: DateTime(2026, 9, 8),
      confidence: 65,
      symptoms: [
        'Manchas amarillo-anaranjadas en polvo en el envés.',
        'Defoliación progresiva de la planta.',
      ],
      recommendations: [
        'Mejorar el manejo de sombra del cultivo.',
        'Podar para favorecer la ventilación.',
      ],
    ),
    DiagnosisRecord(
      id: '4',
      cropId: 'maiz',
      cropName: 'Maíz',
      pathogen: 'Puccinia sorghi',
      pathogenType: 'Hongo',
      date: DateTime(2026, 8, 30),
      confidence: 88,
      symptoms: [
        'Pústulas de color café rojizo en ambas caras de la hoja.',
        'Amarillamiento alrededor de las pústulas.',
      ],
      recommendations: [
        'Monitorear la evolución de los síntomas.',
        'Evaluar variedades con mayor tolerancia para el próximo ciclo.',
      ],
    ),
  ];

  static DiagnosisRecord? byId(String id) {
    for (final record in all) {
      if (record.id == id) return record;
    }
    return null;
  }
}
