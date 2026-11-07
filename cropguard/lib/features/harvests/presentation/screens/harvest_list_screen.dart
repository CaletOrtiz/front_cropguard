import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/refresh/plot_data_refresh.dart';
import 'package:kroppi/core/utils/number_format.dart';
import 'package:kroppi/core/widgets/module_states.dart';
import 'package:kroppi/navigation/app_routes.dart';

import '../../domain/entities/harvest.dart';
import '../cubit/harvest_list_cubit.dart';

class HarvestListScreen extends StatefulWidget {
  const HarvestListScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<HarvestListScreen> createState() => _HarvestListScreenState();
}

class _HarvestListScreenState extends State<HarvestListScreen> {
  final _refresh = PlotDataRefreshNotifier.instance;

  @override
  void initState() {
    super.initState();
    context.read<HarvestListCubit>().load();
    _refresh.addListener(_onPlotChanged);
  }

  @override
  void dispose() {
    _refresh.removeListener(_onPlotChanged);
    super.dispose();
  }

  void _onPlotChanged() {
    if (_refresh.lastPlotId == widget.plotId && mounted) {
      context.read<HarvestListCubit>().load();
    }
  }

  Future<void> _pickRange() async {
    final cubit = context.read<HarvestListCubit>();
    final state = cubit.state;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: today(),
      initialDateRange: state.from != null && state.to != null
          ? DateTimeRange(start: state.from!, end: state.to!)
          : null,
    );
    if (range != null) await cubit.setRange(range.start, range.end);
  }

  Future<void> _delete(Harvest harvest) async {
    if (!await confirmDelete(context, '¿Eliminar esta cosecha?')) return;
    if (!mounted) return;
    final failure = await context.read<HarvestListCubit>().delete(harvest.id);
    if (!mounted) return;
    if (failure == null) {
      _refresh.plotChanged(widget.plotId);
    } else if (!handleCommonFailure(context, failure)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  void _openNew() => context.push(AppRoutes.harvestNewPath(widget.plotId));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cosechas'),
      actions: [
        IconButton(
          tooltip: 'Filtrar por fechas',
          onPressed: _pickRange,
          icon: const Icon(Icons.date_range),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openNew,
      icon: const Icon(Icons.add),
      label: const Text('Registrar cosecha'),
    ),
    body: BlocConsumer<HarvestListCubit, HarvestListState>(
      listenWhen: (previous, current) =>
          current.failure != null && current.failure != previous.failure,
      listener: (context, state) {
        final failure = state.failure!;
        if (handleCommonFailure(context, failure)) return;
        if (state.status == HarvestListStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<HarvestListCubit>();
        if (state.status == HarvestListStatus.loading && state.items.isEmpty) {
          return const SkeletonList();
        }
        if (state.status == HarvestListStatus.failure && state.items.isEmpty) {
          return ModuleErrorView(
            message: state.failure?.message ?? 'No se pudo cargar.',
            onRetry: cubit.load,
          );
        }
        return Column(
          children: [
            if (state.from != null && state.to != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(formatPeriod(state.from!, state.to!)),
                    onDeleted: () => cubit.setRange(null, null),
                  ),
                ),
              ),
            Expanded(
              child: state.isEmpty
                  ? ModuleEmptyView(
                      icon: Icons.agriculture,
                      title: 'Sin cosechas',
                      subtitle: state.from == null
                          ? 'Registra la primera cosecha de este lote.'
                          : 'No hay cosechas en este rango de fechas.',
                      actionLabel: 'Registrar cosecha',
                      onAction: _openNew,
                    )
                  : RefreshIndicator(
                      onRefresh: cubit.load,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.extentAfter < 200) {
                            cubit.loadMore();
                          }
                          return false;
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                          children: [
                            _TotalsCard(totals: state.totals),
                            const SizedBox(height: 12),
                            for (final harvest in state.items)
                              _HarvestCard(
                                harvest: harvest,
                                onOpen: () => context.push(
                                  AppRoutes.harvestDetailPath(
                                    widget.plotId,
                                    harvest.id,
                                  ),
                                ),
                                onDelete: () => _delete(harvest),
                              ),
                            if (state.loadingMore)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final HarvestTotals totals;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total cosechado',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            formatKg(totals.quantityKg),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          // Un total por moneda: COP y USD nunca se suman.
          for (final row in totals.byCurrency)
            Text(
              'Valor ${row.currency}: ${formatMoney(row.revenue, row.currency)}'
              ' (${row.harvestsWithPrice} con precio)',
            ),
          if (totals.harvestsWithoutPrice > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${totals.harvestsWithoutPrice} cosechas sin precio: '
              'los ingresos pueden estar subestimados',
              style: const TextStyle(color: AppColors.warning),
            ),
          ],
        ],
      ),
    ),
  );
}

class _HarvestCard extends StatelessWidget {
  const _HarvestCard({
    required this.harvest,
    required this.onOpen,
    required this.onDelete,
  });

  final Harvest harvest;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final price = harvest.pricePerKg;
    final details = [
      if (price != null)
        '${formatMoney(price, harvest.currency)}/kg'
      else
        'Sin precio',
      if (harvest.value != null)
        'Valor: ${formatMoney(harvest.value, harvest.currency)}',
    ].join(' · ');
    return Dismissible(
      key: ValueKey(harvest.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      // La lista se recarga tras borrar; no se descarta localmente.
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        child: ListTile(
          onTap: onOpen,
          title: Text(
            '${formatDay(harvest.harvestedAt)} · '
            '${formatKg(harvest.quantityKg)}',
          ),
          subtitle: Text(
            [
              details,
              if (harvest.notes?.isNotEmpty ?? false) harvest.notes!,
            ].join('\n'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => value == 'edit' ? onOpen() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ),
      ),
    );
  }
}
