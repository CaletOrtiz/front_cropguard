import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/refresh/plot_data_refresh.dart';
import 'package:kroppi/core/utils/number_format.dart';
import 'package:kroppi/core/widgets/module_states.dart';
import 'package:kroppi/navigation/app_routes.dart';

import '../../domain/entities/loss_estimation.dart';
import '../cubit/loss_list_cubit.dart';
import '../utils/loss_rules.dart';

class LossListScreen extends StatefulWidget {
  const LossListScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<LossListScreen> createState() => _LossListScreenState();
}

class _LossListScreenState extends State<LossListScreen> {
  final _refresh = PlotDataRefreshNotifier.instance;

  @override
  void initState() {
    super.initState();
    context.read<LossListCubit>().load();
    _refresh.addListener(_onPlotChanged);
  }

  @override
  void dispose() {
    _refresh.removeListener(_onPlotChanged);
    super.dispose();
  }

  void _onPlotChanged() {
    if (_refresh.lastPlotId == widget.plotId && mounted) {
      context.read<LossListCubit>().load();
    }
  }

  void _openNew() => context.push(AppRoutes.lossNewPath(widget.plotId));

  Future<void> _delete(LossEstimation estimation) async {
    if (!await confirmDelete(context, '¿Eliminar esta estimación?')) return;
    if (!mounted) return;
    final failure = await context.read<LossListCubit>().delete(estimation.id!);
    if (!mounted) return;
    if (failure == null) {
      _refresh.plotChanged(widget.plotId);
    } else if (!handleCommonFailure(context, failure)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pérdida estimada')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openNew,
      icon: const Icon(Icons.add),
      label: const Text('Nueva estimación'),
    ),
    body: BlocConsumer<LossListCubit, LossListState>(
      listenWhen: (previous, current) =>
          current.failure != null && current.failure != previous.failure,
      listener: (context, state) {
        if (handleCommonFailure(context, state.failure!)) return;
        if (state.status == LossListStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<LossListCubit>();
        if (state.status == LossListStatus.loading && state.items.isEmpty) {
          return const SkeletonList();
        }
        if (state.status == LossListStatus.failure && state.items.isEmpty) {
          return ModuleErrorView(
            message: state.failure?.message ?? 'No se pudo cargar.',
            onRetry: cubit.load,
          );
        }
        if (state.isEmpty) {
          return ModuleEmptyView(
            icon: Icons.trending_down,
            title: 'Sin estimaciones',
            subtitle: 'Aún no has estimado pérdidas. Calcula la primera',
            actionLabel: 'Nueva estimación',
            onAction: _openNew,
          );
        }
        return RefreshIndicator(
          onRefresh: cubit.load,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 200) cubit.loadMore();
              return false;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                for (final estimation in state.items)
                  _LossCard(
                    estimation: estimation,
                    onOpen: () => context.push(
                      AppRoutes.lossDetailPath(widget.plotId, estimation.id!),
                    ),
                    onDelete: () => _delete(estimation),
                  ),
                if (state.loadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _LossCard extends StatelessWidget {
  const _LossCard({
    required this.estimation,
    required this.onOpen,
    required this.onDelete,
  });

  final LossEstimation estimation;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = lossSeverityColor(lossSeverity(estimation.lossPct));
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatPeriod(estimation.periodFrom, estimation.periodTo),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Esperados ${formatKg(estimation.expectedYieldKg)} · '
                      'cosechados ${formatKg(estimation.harvestedKg)} · '
                      'perdidos ${formatKg(estimation.lostKg)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monto perdido: '
                      '${formatMoney(estimation.estimatedLossAmount, estimation.currency)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(formatPct(estimation.lossPct)),
                backgroundColor: color.withValues(alpha: 0.15),
                side: BorderSide(color: color),
                labelStyle: TextStyle(color: color),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => value == 'edit' ? onOpen() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
