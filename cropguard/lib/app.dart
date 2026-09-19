import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/navigation/app_router.dart';
import 'package:cropguard/presentation/themes/app_theme.dart';

class CropGuardApp extends StatelessWidget {
  const CropGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      // Limita el ancho para previsualizar como móvil en web/escritorio
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFF3F4F6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        ),
      ),
    );
  }
}
