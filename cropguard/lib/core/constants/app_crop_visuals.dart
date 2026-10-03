import 'package:flutter/material.dart';

/// Ícono y color representativos por cultivo, usados en la insignia de la
/// tarjeta y como respaldo mientras no haya fotos reales.
class AppCropVisuals {
  AppCropVisuals._();

  static const Map<String, IconData> _icons = {
    'tomate': Icons.local_florist_rounded,
    'papa': Icons.eco_rounded,
    'cafe': Icons.coffee_rounded,
    'platano': Icons.spa_rounded,
    'maiz': Icons.grass_rounded,
    'otros': Icons.agriculture_rounded,
  };

  static const Map<String, Color> _colors = {
    'tomate': Color(0xFFE5533D),
    'papa': Color(0xFFD9A441),
    'cafe': Color(0xFF2F6B3A),
    'platano': Color(0xFF4C9A2A),
    'maiz': Color(0xFF8CC63F),
    'otros': Color(0xFF1F5F3A),
  };

  static IconData iconFor(String cropId) => _icons[cropId] ?? Icons.eco_rounded;

  static Color colorFor(String cropId) =>
      _colors[cropId] ?? const Color(0xFF2E9E4F);
}
