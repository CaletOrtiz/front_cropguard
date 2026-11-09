import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_event.dart';
import 'package:kroppi/features/profile/domain/entities/plan_catalog.dart';
import 'package:kroppi/features/profile/presentation/cubit/plan_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> with WidgetsBindingObserver {
  bool _awaitingCheckoutReturn = false;
  bool _openingCheckout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<PlanCubit>().refreshProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingCheckoutReturn) {
      _awaitingCheckoutReturn = false;
      unawaited(context.read<PlanCubit>().refreshProfile());
    }
  }

  Future<void> _purchase() async {
    if (_openingCheckout ||
        context.read<PlanCubit>().state.isCreatingCheckout) {
      return;
    }
    setState(() => _openingCheckout = true);
    try {
      final checkoutUri = await context.read<PlanCubit>().createCheckout();
      if (checkoutUri == null || !mounted) return;

      _awaitingCheckoutReturn = true;
      final opened = await launchUrl(
        checkoutUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _awaitingCheckoutReturn = false;
        _showMessage('No se pudo abrir la página de pago.');
      }
    } catch (error) {
      _awaitingCheckoutReturn = false;
      if (mounted) _showMessage('No se pudo abrir el pago: $error');
    } finally {
      if (mounted) setState(() => _openingCheckout = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PlanCubit, PlanState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) => _showMessage(state.errorMessage!),
        ),
        BlocListener<PlanCubit, PlanState>(
          listenWhen: (previous, current) =>
              previous.user != current.user && current.user != null,
          listener: (context, state) {
            context.read<AuthBloc>().add(AuthUserUpdated(state.user!));
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Planes')),
        body: SafeArea(
          child: BlocBuilder<PlanCubit, PlanState>(
            builder: (context, state) {
              final user = state.user;
              if (user == null) {
                if (state.errorMessage == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No se pudo consultar tu plan.'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: state.isRefreshingProfile
                              ? null
                              : () =>
                                    context.read<PlanCubit>().refreshProfile(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final now = DateTime.now().toUtc();
              final isPremium = user.isPremiumActiveAt(now);
              final isExpired = user.isPremiumExpiredAt(now);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  if (state.isRefreshingProfile)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  _CurrentPlanCard(
                    planName: isPremium ? 'Premium' : 'Free',
                    isPremium: isPremium,
                    isExpired: isExpired,
                    premiumUntil: user.premiumUntil,
                  ),
                  const SizedBox(height: 20),
                  _PlanCard(
                    title: 'Free',
                    subtitle: 'Para comenzar a gestionar tu finca',
                    price: 'Gratis',
                    benefits: PlanCatalog.freeBenefits,
                    active: !isPremium,
                    activeLabel: 'Plan actual',
                  ),
                  const SizedBox(height: 16),
                  _PlanCard(
                    title: 'Premium',
                    subtitle: 'Más capacidad y análisis para tu producción',
                    price:
                        '\$${NumberFormat.decimalPattern('es_CO').format(PlanCatalog.premiumPriceInCop)} '
                        'COP / ${PlanCatalog.premiumDurationDays} días',
                    benefits: PlanCatalog.premiumBenefits,
                    active: isPremium,
                    activeLabel: 'Premium activo',
                    action: isPremium
                        ? null
                        : FilledButton.icon(
                            onPressed:
                                _openingCheckout || state.isCreatingCheckout
                                ? null
                                : _purchase,
                            icon: _openingCheckout || state.isCreatingCheckout
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.lock_open_rounded),
                            label: const Text('Adquirir Premium'),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Los límites y accesos que se muestran aquí son informativos. '
                    'La validación de uso y la activación del plan deben ser '
                    'confirmadas por el backend.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.planName,
    required this.isPremium,
    required this.isExpired,
    required this.premiumUntil,
  });

  final String planName;
  final bool isPremium;
  final bool isExpired;
  final DateTime? premiumUntil;

  @override
  Widget build(BuildContext context) {
    final status = isPremium
        ? 'Premium activo'
        : isExpired
        ? 'Premium vencido'
        : 'Plan gratuito';
    final detail = isPremium && premiumUntil != null
        ? 'Vence el ${DateFormat('d MMM yyyy, HH:mm', 'es').format(premiumUntil!.toLocal())}'
        : isExpired
        ? 'Venció el ${DateFormat('d MMM yyyy, HH:mm', 'es').format(premiumUntil!.toLocal())}. '
              'Tu cuenta ahora está en Free; puedes adquirir Premium nuevamente.'
        : 'Actualmente estás usando el plan gratuito.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu plan actual',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  planName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isPremium)
                const Icon(Icons.verified_rounded, color: AppColors.mint),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: const TextStyle(
              color: AppColors.mint,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.benefits,
    required this.active,
    required this.activeLabel,
    this.action,
  });

  final String title;
  final String subtitle;
  final String price;
  final List<String> benefits;
  final bool active;
  final String activeLabel;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final borderColor = active ? AppColors.primary : AppColors.border;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: active ? 2 : 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (active)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    activeLabel,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 24),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 19,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(benefit)),
                ],
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 6),
            SizedBox(width: double.infinity, child: action),
          ],
        ],
      ),
    );
  }
}
