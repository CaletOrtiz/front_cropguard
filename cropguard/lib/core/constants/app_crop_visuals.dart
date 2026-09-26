import 'package:flutter/material.dart';

/// Ícono representativo por cultivo, usado mientras no haya fotos reales.
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

  static IconData iconFor(String cropId) => _icons[cropId] ?? Icons.eco_rounded;
}
