import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/presentation/screens/recommendations/widgets/recommendation_card.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  static const _items = [
    (
      Icons.sync_alt_rounded,
      'Rotación de cultivos',
      'Alterna especies distintas en el mismo terreno para reducir la acumulación de patógenos.',
    ),
    (
      Icons.visibility_rounded,
      'Monitoreo constante',
      'Revisa tus cultivos con regularidad para detectar signos tempranos de enfermedad.',
    ),
    (
      Icons.air_rounded,
      'Buena ventilación',
      'Deja espacio entre plantas para que el aire circule y reduzca la humedad en el follaje.',
    ),
    (
      Icons.handyman_rounded,
      'Manejo adecuado',
      'Poda, riega y fertiliza siguiendo las necesidades de cada cultivo.',
    ),
    (
      Icons.science_outlined,
      'Uso responsable de insumos',
      'Aplica fungicidas y agroquímicos solo cuando sea necesario y bajo las dosis recomendadas.',
    ),
    (
      Icons.shield_rounded,
      'Prevención de enfermedades',
      'Combina buenas prácticas para reducir el riesgo antes de que aparezcan los síntomas.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.recommendationsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Text(
              AppStrings.recommendationsSubtitle,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecommendationCard(
                  icon: item.$1,
                  title: item.$2,
                  description: item.$3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
