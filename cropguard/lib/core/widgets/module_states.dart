import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/errors/failures.dart';
import 'package:kroppi/core/widgets/empty_state.dart';
import 'package:kroppi/navigation/app_routes.dart';

/// Estados comunes de las pantallas de datos de los módulos del lote:
/// cargando (skeleton), vacío, error y la reacción estándar a fallos.

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 4, this.height = 92});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: count,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (_, _) => Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

class ModuleEmptyView extends StatelessWidget {
  const ModuleEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      EmptyState(icon: icon, title: title, subtitle: subtitle),
      Center(
        child: FilledButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add),
          label: Text(actionLabel),
        ),
      ),
    ],
  );
}

class ModuleErrorView extends StatelessWidget {
  const ModuleErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}

/// 401 → login; 404 → avisa y vuelve atrás. Devuelve true si ya lo manejó.
bool handleCommonFailure(BuildContext context, Failure failure) {
  if (failure is AuthFailure) {
    context.go(AppRoutes.login);
    return true;
  }
  if (failure is NotFoundFailure) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Este registro ya no existe')));
    if (context.canPop()) context.pop(true);
    return true;
  }
  return false;
}

/// Pregunta antes de salir si hay cambios sin guardar.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Descartar cambios?'),
      content: const Text('Tienes cambios sin guardar.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Seguir editando'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Descartar'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> confirmDelete(BuildContext context, String question) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(question),
      content: const Text('Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return result ?? false;
}
