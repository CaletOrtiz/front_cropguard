import 'package:kroppi/core/errors/failures.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/navigation/app_routes.dart';

import '../../domain/entities/subscription_access.dart';
import '../cubit/subscription_cubit.dart';

class SubscriptionGate extends StatefulWidget {
  const SubscriptionGate({
    super.key,
    this.resource,
    this.premium = false,
    this.freeAction,
    required this.builder,
  });

  final PlanResource? resource;
  final bool premium;
  final Widget? freeAction;
  final Widget Function(SubscriptionAccess access) builder;

  @override
  State<SubscriptionGate> createState() => _SubscriptionGateState();
}

class _SubscriptionGateState extends State<SubscriptionGate> {
  bool _checked = false;
  SubscriptionAccess? _formAccess;
  bool get _openedForm => _formAccess != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<SubscriptionCubit>().refresh();
      if (mounted) setState(() => _checked = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscriptionCubit>().state;
    final access = state.access;
    final resource = widget.resource;
    if (_openedForm && access == null && _formAccess != null) {
      return widget.builder(_formAccess!);
    }
    if (_checked && access != null) {
      if (widget.premium && !access.premiumFeatures) {
        return _message(
          'Esta función requiere un plan Premium activo.',
          actions: [
            if (widget.freeAction != null) widget.freeAction!,
            const ViewPlansButton(),
          ],
        );
      }
      if (resource != null &&
          !_openedForm &&
          access.quota(resource).exhausted) {
        return _message(
          creationLimitMessage(access, resource),
          actions: [if (!access.premiumFeatures) const ViewPlansButton()],
        );
      }
      if (resource != null) _formAccess = access;
      return widget.builder(access);
    }
    return _message(
      state.error ?? 'Inicia sesión para consultar tu plan.',
      loading: !_checked || state.loading,
      actions: [
        TextButton(
          onPressed: context.read<SubscriptionCubit>().refresh,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }

  Widget _message(
    String message, {
    bool loading = false,
    required List<Widget> actions,
  }) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso según tu plan')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    ...actions,
                  ],
                ),
              ),
      ),
    );
  }
}

String creationLimitMessage(SubscriptionAccess access, PlanResource resource) {
  final quota = access.quota(resource);
  final name = resource.label.toLowerCase();
  return 'Alcanzaste el límite de $name de tu plan '
      '(${quota.used} registrados, máximo ${quota.limit}). '
      'Puedes seguir consultando y editando tus registros.';
}

class ViewPlansButton extends StatelessWidget {
  const ViewPlansButton({super.key});

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => context.push(AppRoutes.plans),
    child: const Text('Consultar planes'),
  );
}

class DiagnosisQuotaNotice extends StatelessWidget {
  const DiagnosisQuotaNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscriptionCubit>().state;
    final access = state.access;
    if (access == null) {
      return state.loading
          ? const LinearProgressIndicator()
          : TextButton(
              onPressed: context.read<SubscriptionCubit>().refresh,
              child: const Text('Reintentar consulta de cuota de IA'),
            );
    }
    final quota = access.quota(PlanResource.diagnoses);
    final renewal = DateFormat(
      'd MMM yyyy, HH:mm',
      'es',
    ).format(access.renewsAt.toUtc().subtract(const Duration(hours: 5)));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Diagnósticos con IA · ${quota.summary}'),
        if (quota.exhausted) ...[
          Text(
            'Tu cuota se renueva el $renewal (hora de Colombia).',
            textAlign: TextAlign.center,
          ),
          if (!access.premiumFeatures) const ViewPlansButton(),
        ],
      ],
    );
  }
}

class SubscriptionNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is! PageRoute) return;
    final context = navigator?.context;
    if (context != null) {
      final subscription = context.read<SubscriptionCubit>();
      scheduleMicrotask(subscription.refresh);
    }
  }
}

Future<void> checkCreationQuota(
  BuildContext context,
  PlanResource resource,
) async {
  final subscription = context.read<SubscriptionCubit>();
  await subscription.refresh();
  final state = subscription.state;
  final access = state.access;
  if (access == null) {
    throw ServerFailure(state.error ?? 'No se pudo consultar tu plan.');
  }
  if (access.quota(resource).exhausted) {
    throw ValidationFailure(creationLimitMessage(access, resource));
  }
}
