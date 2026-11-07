import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/core/refresh/plot_data_refresh.dart';
import 'package:kroppi/core/utils/number_format.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';
import 'package:kroppi/features/plot_stats/domain/entities/plot_stats.dart';
import 'package:kroppi/features/plot_stats/presentation/widgets/stats_charts.dart';

class PlotStatsScreen extends StatefulWidget {
  const PlotStatsScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<PlotStatsScreen> createState() => _PlotStatsScreenState();
}

class _PlotStatsScreenState extends State<PlotStatsScreen> {
  final _source = PlotModulesRemoteDataSource();
  final _refresh = PlotDataRefreshNotifier.instance;
  DateTime _from = DateTime.now().subtract(const Duration(days: 183));
  DateTime _to = DateTime.now();
  String _granularity = 'month';
  PlotStats? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _refresh.addListener(_onPlotChanged);
  }

  @override
  void dispose() {
    _refresh.removeListener(_onPlotChanged);
    super.dispose();
  }

  void _onPlotChanged() {
    if (_refresh.lastPlotId == widget.plotId && mounted) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _source.getStats(
        widget.plotId,
        from: _from,
        to: _to,
        granularity: _granularity,
      );
      if (mounted) {
        setState(() {
          _data = PlotStats.fromJson(response);
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = apiErrorMessage(error);
          _loading = false;
        });
      }
    }
  }

  Future<void> _customRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (range == null) return;
    setState(() {
      _from = range.start;
      _to = range.end;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Estadísticas del lote')),
    body: _loading && _data == null
        ? const Center(child: CircularProgressIndicator())
        : _error != null && _data == null
        ? _ErrorView(message: _error!, onRetry: _load)
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    _periodChip('3 meses', 90),
                    _periodChip('6 meses', 183),
                    _periodChip('1 año', 365),
                    ActionChip(
                      label: const Text('Personalizado'),
                      onPressed: _customRange,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'week', label: Text('Semanal')),
                    ButtonSegment(value: 'month', label: Text('Mensual')),
                  ],
                  selected: {_granularity},
                  onSelectionChanged: (value) {
                    setState(() => _granularity = value.first);
                    _load();
                  },
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_data != null) ..._buildStats(_data!),
                if (_loading) const LinearProgressIndicator(),
              ],
            ),
          ),
  );

  Widget _periodChip(String label, int days) => ChoiceChip(
    label: Text(label),
    selected:
        DateTime.now().difference(_from).inDays >= days - 10 &&
        DateTime.now().difference(_from).inDays <= days + 10,
    onSelected: (_) {
      setState(() => _from = DateTime.now().subtract(Duration(days: days)));
      _load();
    },
  );

  List<Widget> _buildStats(PlotStats data) {
    final totals = data.totals;
    final currency = data.currency;
    String money(num value) => formatMoney(value, currency);
    final incidence = data.incidenceSeries;
    final harvest = data.harvestSeries;
    final losses = data.lossSeries;
    final income = data.incomeSeries;
    final expected = data.expectedVsHarvested;
    final excluded = data.excludedOtherCurrency;
    String sampleLabel(IncidencePoint point, String pattern) =>
        point.sampledAt == null
        ? ''
        : DateFormat(pattern, 'es').format(point.sampledAt!);
    return [
      if (data.mixedCurrency)
        _Banner(
          'Hay registros en otra moneda que no se incluyen en estas gráficas'
          '${excluded == null ? '' : ' (${excluded.count} en ${excluded.currency})'}.',
        ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Summary('Muestreos', '${totals.samples}'),
          _Summary('Incidencia promedio', formatPct(totals.avgIncidencePct)),
          _Summary('Incidencia máxima', formatPct(totals.maxIncidencePct)),
          _Summary('Cosecha', formatKg(totals.harvestedKg)),
          _Summary('Kg esperados', formatKg(totals.expectedKg)),
          _Summary('Kg perdidos', formatKg(totals.lostKg)),
          _Summary(
            '% de pérdida global',
            totals.lossPctOverall == null
                ? 'Sin dato'
                : formatPct(totals.lossPctOverall),
          ),
          _Summary('Ingresos', money(totals.revenue)),
          _Summary('Pérdidas', money(totals.lossAmount)),
          _Summary('Costo de cuidados', formatMoney(totals.careCostCop, 'COP')),
        ],
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Incidencia en el tiempo',
        subtitle:
            'Los estados se calculan con los umbrales vigentes del cultivo.',
        empty: incidence.isEmpty,
        child: SimpleLineChart(
          values: [for (final point in incidence) point.incidencePct],
          labels: [for (final point in incidence) sampleLabel(point, 'd MMM')],
          tooltip: formatPct,
          minY: 0,
          showDots: true,
          extraLines: [
            HorizontalLine(
              y: data.alertPct,
              color: Colors.amber,
              dashArray: [6, 4],
            ),
            HorizontalLine(
              y: data.dangerPct,
              color: Colors.red,
              dashArray: [6, 4],
            ),
          ],
        ),
      ),
      if (incidence.length == 1)
        const _Hint('Necesitas al menos 2 muestreos para ver la tendencia.'),
      _ChartCard(
        title: 'Plantas afectadas',
        subtitle: 'Plantas afectadas y evaluadas en cada muestreo.',
        empty: incidence.isEmpty,
        child: SimpleBarChart(
          values: [
            for (final point in incidence) point.plantsAffected.toDouble(),
          ],
          labels: [for (final point in incidence) sampleLabel(point, 'd/M')],
        ),
      ),
      _ChartCard(
        title: 'Evolución de la salud del lote',
        subtitle:
            'Sano = no se detectó enfermedad; estados orientativos según incidencia.',
        empty: data.healthEvolution.isEmpty,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: data.healthEvolution.map((row) {
            final status = row['status'] as String;
            final color = status == 'peligro'
                ? Colors.red
                : status == 'alerta'
                ? Colors.amber
                : Colors.green;
            return Chip(
              avatar: CircleAvatar(backgroundColor: color, radius: 7),
              label: Text('${row['date']} · $status'),
            );
          }).toList(),
        ),
      ),
      _ChartCard(
        title: 'Enfermedades detectadas',
        subtitle: 'Porcentaje sobre los diagnósticos con enfermedad detectada.',
        empty: data.diseaseBreakdown.isEmpty,
        child: SimpleBarChart(
          values: [
            for (final row in data.diseaseBreakdown)
              toDouble(row['count']) ?? 0,
          ],
          labels: [
            for (final row in data.diseaseBreakdown)
              row['disease_name'].toString(),
          ],
        ),
      ),
      _ChartCard(
        title: 'Kg cosechados por periodo',
        subtitle: 'Cantidad de cosecha registrada.',
        empty: harvest.isEmpty || harvest.every((row) => row.kg == 0),
        child: SimpleBarChart(
          values: [for (final row in harvest) row.kg],
          labels: [for (final row in harvest) row.period],
          tooltip: formatKg,
        ),
      ),
      _ChartCard(
        title: 'Esperado vs. cosechado',
        subtitle: 'Kilos esperados (estimaciones de pérdidas) y cosechados.',
        empty: expected.isEmpty,
        emptyText: 'Registra una estimación de pérdidas para comparar',
        child: ExpectedVsHarvestedChart(
          periods: [for (final row in expected) row.period],
          expected: [for (final row in expected) row.expectedKg],
          harvested: [for (final row in expected) row.harvestedKg],
        ),
      ),
      _ChartCard(
        title: 'Pérdidas económicas acumuladas',
        subtitle: 'Estimaciones de pérdidas guardadas ($currency).',
        empty: losses.isEmpty || losses.every((row) => row.lossAmount == 0),
        child: SimpleLineChart(
          values: [for (final row in losses) row.cumulativeLossAmount],
          labels: [for (final row in losses) row.period],
          tooltip: money,
          minY: 0,
        ),
      ),
      _ChartCard(
        title: 'Ingresos generados',
        subtitle:
            'Barras: ingresos por periodo · línea: ingresos acumulados ($currency).',
        empty: income.isEmpty || income.every((row) => row.revenue == 0),
        child: Column(
          children: [
            SimpleBarChart(
              values: [for (final row in income) row.revenue],
              labels: [for (final row in income) row.period],
              tooltip: money,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ingresos acumulados',
                style: TextStyle(fontSize: 12),
              ),
            ),
            SimpleLineChart(
              values: [for (final row in income) row.cumulativeRevenue],
              labels: [for (final row in income) row.period],
              tooltip: money,
              minY: 0,
            ),
          ],
        ),
      ),
      if (data.harvestsWithoutPrice > 0)
        _Hint(
          'Hay ${data.harvestsWithoutPrice} cosecha(s) sin precio: los ingresos pueden estar subestimados.',
        ),
    ];
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: AppColors.warning),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 155,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 5),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    ),
  );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.empty,
    required this.child,
    this.emptyText = 'Sin datos en este periodo',
  });

  final String title;
  final String subtitle;
  final bool empty;
  final Widget child;
  final String emptyText;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          if (empty)
            SizedBox(
              height: 80,
              child: Center(
                child: Text(emptyText, textAlign: TextAlign.center),
              ),
            )
          else
            child,
        ],
      ),
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    ),
  );
}
