import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/plot_modules/data/plot_modules_remote_data_source.dart';

class PlotStatsScreen extends StatefulWidget {
  const PlotStatsScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<PlotStatsScreen> createState() => _PlotStatsScreenState();
}

class _PlotStatsScreenState extends State<PlotStatsScreen> {
  final _source = PlotModulesRemoteDataSource();
  DateTime _from = DateTime.now().subtract(const Duration(days: 183));
  DateTime _to = DateTime.now();
  String _granularity = 'month';
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
          _data = response;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = _errorMessage(error);
          _loading = false;
        });
      }
    }
  }

  String _errorMessage(Object error) {
    return apiErrorMessage(error);
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
                        child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
    selected: DateTime.now().difference(_from).inDays >= days - 10 &&
        DateTime.now().difference(_from).inDays <= days + 10,
    onSelected: (_) {
      setState(() => _from = DateTime.now().subtract(Duration(days: days)));
      _load();
    },
  );

  List<Widget> _buildStats(Map<String, dynamic> data) {
    final totals = data['totals'] as Map<String, dynamic>;
    final incidence = (data['incidence_series'] as List).cast<Map<String, dynamic>>();
    final health = (data['health_evolution'] as List).cast<Map<String, dynamic>>();
    final diseases = (data['disease_breakdown'] as List).cast<Map<String, dynamic>>();
    final harvest = (data['harvest_series'] as List).cast<Map<String, dynamic>>();
    final losses = (data['loss_series'] as List).cast<Map<String, dynamic>>();
    final income = (data['income_series'] as List).cast<Map<String, dynamic>>();
    final thresholds = data['thresholds'] as Map<String, dynamic>;
    final withoutPrice = (data['harvests_without_price'] as num?)?.toInt() ?? 0;
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Summary('Muestreos', '${totals['samples']}'),
          _Summary('Incidencia promedio', '${_number(totals['avg_incidence_pct'])} %'),
          _Summary('Incidencia máxima', '${_number(totals['max_incidence_pct'])} %'),
          _Summary('Cosecha', '${_number(totals['harvested_kg'])} kg'),
          _Summary('Ingresos', _cop(totals['revenue_cop'])),
          _Summary('Pérdidas', _cop(totals['loss_amount_cop'])),
          _Summary('Costo de cuidados', _cop(totals['care_cost_cop'])),
        ],
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Incidencia en el tiempo',
        subtitle: 'Los estados se calculan con los umbrales vigentes del cultivo.',
        empty: incidence.isEmpty,
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(y: (thresholds['alert_pct'] as num).toDouble(), color: Colors.amber, dashArray: [6, 4]),
                HorizontalLine(y: (thresholds['danger_pct'] as num).toDouble(), color: Colors.red, dashArray: [6, 4]),
              ]),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  dotData: const FlDotData(show: true),
                  spots: [
                    for (var i = 0; i < incidence.length; i++)
                      FlSpot(i.toDouble(), _number(incidence[i]['incidence_pct'])),
                  ],
                ),
              ],
              titlesData: _axisTitles(incidence.length, (i) {
                final value = DateTime.tryParse(incidence[i]['sampled_at'] as String? ?? '');
                return value == null ? '' : DateFormat('d MMM', 'es').format(value.toLocal());
              }),
            ),
          ),
        ),
      ),
      if (incidence.length == 1) const _Hint('Necesitas al menos 2 muestreos para ver la tendencia.'),
      _ChartCard(
        title: 'Plantas afectadas',
        subtitle: 'Plantas afectadas y evaluadas en cada muestreo.',
        empty: incidence.isEmpty,
        child: _bars(
          incidence.map((row) => row['plants_affected']).toList(),
          labels: incidence.map((row) {
            final value = DateTime.tryParse(row['sampled_at'] as String? ?? '');
            return value == null ? '' : DateFormat('d/M').format(value.toLocal());
          }).toList(),
        ),
      ),
      _ChartCard(
        title: 'Evolución de la salud del lote',
        subtitle: 'Sano = no se detectó enfermedad; estados orientativos según incidencia.',
        empty: health.isEmpty,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: health.map((row) {
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
        empty: diseases.isEmpty,
        child: _bars(
          diseases.map((row) => row['count']).toList(),
          labels: diseases.map((row) => row['disease_name'].toString()).toList(),
        ),
      ),
      _ChartCard(
        title: 'Kg cosechados por periodo',
        subtitle: 'Cantidad de cosecha registrada.',
        empty: harvest.isEmpty || harvest.every((row) => _number(row['kg']) == 0),
        child: _bars(harvest.map((row) => row['kg']).toList(),
          labels: harvest.map((row) => row['period'].toString()).toList()),
      ),
      _ChartCard(
        title: 'Pérdidas económicas acumuladas',
        subtitle: 'Estimaciones registradas durante el periodo.',
        empty: losses.isEmpty || losses.every((row) => _number(row['loss_amount_cop']) == 0),
        child: _line(losses.map((row) => row['cumulative_loss_amount_cop']).toList()),
      ),
      _ChartCard(
        title: 'Ingresos generados',
        subtitle: 'Barras: ingresos por periodo · línea: ingresos acumulados.',
        empty: income.isEmpty || income.every((row) => _number(row['revenue_cop']) == 0),
        child: Column(
          children: [
            _bars(
              income.map((row) => row['revenue_cop']).toList(),
              labels: income.map((row) => row['period'].toString()).toList(),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ingresos acumulados', style: TextStyle(fontSize: 12)),
            ),
            _line(income.map((row) => row['cumulative_revenue_cop']).toList()),
          ],
        ),
      ),
      if (withoutPrice > 0)
        _Hint('Hay $withoutPrice cosecha(s) sin precio: los ingresos pueden estar subestimados.'),
    ];
  }

  Widget _line(List<dynamic> values) => SizedBox(
    height: 200,
    child: LineChart(LineChartData(
      lineBarsData: [LineChartBarData(
        isCurved: true,
        spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), _number(values[i]))],
      )],
      titlesData: _axisTitles(values.length, (index) => '$index'),
    )),
  );

  Widget _bars(List<dynamic> values, {required List<String> labels}) {
    if (values.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 220,
      child: BarChart(BarChartData(
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: _number(values[i]), width: 14, borderRadius: BorderRadius.circular(4))],
            ),
        ],
        titlesData: _axisTitles(labels.length, (index) =>
          index >= 0 && index < labels.length ? labels[index] : ''),
      )),
    );
  }

  FlTitlesData _axisTitles(int count, String Function(int index) label) => FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44)),
    bottomTitles: AxisTitles(sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 42,
      interval: count > 10 ? (count / 6).ceilToDouble() : 1,
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        return SideTitleWidget(
          meta: meta,
          child: Text(index >= 0 && index < count ? label(index) : '', style: const TextStyle(fontSize: 10)),
        );
      },
    )),
  );

  double _number(Object? value) => (value as num?)?.toDouble() ?? 0;

  String _cop(Object? value) => NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$',
    decimalDigits: 0,
  ).format(_number(value));
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
  });

  final String title;
  final String subtitle;
  final bool empty;
  final Widget child;

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
            const SizedBox(height: 80, child: Center(child: Text('Sin datos en este periodo')))
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
    child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
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
