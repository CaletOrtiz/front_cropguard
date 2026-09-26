import 'package:cropguard/core/constants/app_assets.dart';

class Crop {
  const Crop({
    required this.id,
    required this.name,
    required this.commonDiseases,
    required this.symptoms,
    required this.monitoringTips,
    required this.preventionTips,
  });

  final String id;
  final String name;
  final List<String> commonDiseases;
  final List<String> symptoms;
  final List<String> monitoringTips;
  final List<String> preventionTips;

  String get imageAsset => AppAssets.cropImage(id);
}

/// Contenido educativo base. Puede ampliarse o conectarse a un backend luego.
class AppCrops {
  AppCrops._();

  static const List<Crop> all = [
    Crop(
      id: 'tomate',
      name: 'Tomate',
      commonDiseases: ['Tizón temprano', 'Tizón tardío', 'Moho gris'],
      symptoms: [
        'Manchas oscuras con anillos concéntricos en las hojas.',
        'Amarillamiento y caída prematura del follaje.',
        'Lesiones húmedas en tallos y frutos.',
      ],
      monitoringTips: [
        'Revisa el envés de las hojas al menos dos veces por semana.',
        'Presta atención tras periodos de lluvia o alta humedad.',
      ],
      preventionTips: [
        'Mantén distancia entre plantas para favorecer la ventilación.',
        'Evita mojar el follaje al regar.',
        'Retira y elimina restos de plantas enfermas.',
      ],
    ),
    Crop(
      id: 'papa',
      name: 'Papa',
      commonDiseases: ['Tizón tardío', 'Sarna común', 'Pierna negra'],
      symptoms: [
        'Manchas oscuras e irregulares en hojas y tallos.',
        'Lesiones costrosas en la superficie del tubérculo.',
        'Pudrición blanda en la base del tallo.',
      ],
      monitoringTips: [
        'Inspecciona el cultivo con más frecuencia en clima húmedo y fresco.',
        'Revisa los tubérculos al momento de la cosecha.',
      ],
      preventionTips: [
        'Usa semilla certificada y libre de enfermedades.',
        'Rota el cultivo con especies no relacionadas.',
        'Mejora el drenaje del suelo.',
      ],
    ),
    Crop(
      id: 'cafe',
      name: 'Café',
      commonDiseases: ['Roya del cafeto', 'Ojo de gallo', 'Broca del café'],
      symptoms: [
        'Manchas amarillo-anaranjadas en polvo en el envés de la hoja.',
        'Defoliación progresiva de la planta.',
        'Pequeños orificios en los granos de café.',
      ],
      monitoringTips: [
        'Monitorea el envés de las hojas cada 15 días.',
        'Revisa los frutos cerca de la maduración.',
      ],
      preventionTips: [
        'Poda para mejorar la entrada de luz y ventilación.',
        'Maneja la sombra de forma equilibrada.',
        'Elimina frutos caídos que puedan albergar plagas.',
      ],
    ),
    Crop(
      id: 'platano',
      name: 'Plátano',
      commonDiseases: ['Sigatoka negra', 'Mal de Panamá'],
      symptoms: [
        'Rayas y manchas necróticas en las hojas.',
        'Amarillamiento y marchitez de hojas inferiores.',
        'Reducción del tamaño del racimo.',
      ],
      monitoringTips: [
        'Revisa las hojas más viejas primero, donde aparecen los síntomas.',
        'Observa el desarrollo del racimo en cada ciclo.',
      ],
      preventionTips: [
        'Elimina hojas muy afectadas para reducir la propagación.',
        'Evita encharcamientos en el terreno.',
        'Usa material de siembra sano.',
      ],
    ),
    Crop(
      id: 'maiz',
      name: 'Maíz',
      commonDiseases: ['Roya común', 'Tizón foliar', 'Carbón del maíz'],
      symptoms: [
        'Pústulas de color café rojizo en hojas.',
        'Lesiones alargadas de color gris o tostado.',
        'Agallas grisáceas en mazorcas o tallos.',
      ],
      monitoringTips: [
        'Inspecciona el cultivo en etapas tempranas de crecimiento.',
        'Revisa después de periodos cálidos y húmedos.',
      ],
      preventionTips: [
        'Alterna variedades con mayor tolerancia.',
        'Rota cultivos entre temporadas.',
        'Maneja adecuadamente los residuos de cosecha.',
      ],
    ),
    Crop(
      id: 'otros',
      name: 'Otros cultivos',
      commonDiseases: ['Manchas foliares', 'Pudriciones', 'Mildiu'],
      symptoms: [
        'Manchas de color, forma o tamaño irregular en las hojas.',
        'Marchitez o amarillamiento sin causa aparente.',
      ],
      monitoringTips: [
        'Observa el cultivo con regularidad, incluso sin síntomas visibles.',
        'Compara el aspecto de las plantas entre sí para detectar diferencias.',
      ],
      preventionTips: [
        'Mantén buenas prácticas de higiene y ventilación.',
        'Consulta a un especialista ante dudas persistentes.',
      ],
    ),
  ];

  static Crop? byId(String id) {
    for (final crop in all) {
      if (crop.id == id) return crop;
    }
    return null;
  }
}
