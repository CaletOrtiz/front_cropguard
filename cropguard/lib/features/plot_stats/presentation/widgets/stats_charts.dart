import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/utils/number_format.dart';

/// Gráficas del lote como widgets independientes (Estadísticas y cualquier
/// otra pantalla que quiera reutilizarlas).

FlTitlesData chartTitles(
  int count,
  String Function(int index) label, {
  double reservedLeft = 44,
}) => FlTitlesData(
  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  leftTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: true, reservedSize: reservedLeft),
  ),
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 42,
      interval: count > 10 ? (count / 6).ceilToDouble() : 1,
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        return SideTitleWidget(
          meta: meta,
          child: Text(
            index >= 0 && index < count ? label(index) : '',
            style: const TextStyle(fontSize: 10),
          ),
        );
      },
    ),
  ),
);

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.tooltip,
  });

  final List<double> values;
  final List<String> labels;
  final String Function(double value)? tooltip;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                tooltip?.call(rod.toY) ?? rod.toY.toStringAsFixed(1),
                const TextStyle(color: Colors.white),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
          titlesData: chartTitles(labels.length, (i) => labels[i]),
        ),
      ),
    );
  }
}

class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({
    super.key,
    required this.values,
    required this.labels,
    this.tooltip,
    this.minY,
    this.extraLines = const [],
    this.showDots = false,
  });

  final List<double> values;
  final List<String> labels;
  final String Function(double value)? tooltip;
  final double? minY;
  final List<HorizontalLine> extraLines;
  final bool showDots;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        minY: minY,
        extraLinesData: ExtraLinesData(horizontalLines: extraLines),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  tooltip?.call(spot.y) ?? spot.y.toStringAsFixed(1),
                  const TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: !showDots,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
          ),
        ],
        titlesData: chartTitles(labels.length, (i) => labels[i]),
      ),
    ),
  );
}

/// Barras agrupadas: kilos esperados vs. cosechados por periodo.
class ExpectedVsHarvestedChart extends StatelessWidget {
  const ExpectedVsHarvestedChart({
    super.key,
    required this.periods,
    required this.expected,
    required this.harvested,
  });

  static const expectedColor = AppColors.warning;
  static const harvestedColor = AppColors.primary;

  final List<String> periods;
  final List<double> expected;
  final List<double> harvested;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, rod, rodIndex) => BarTooltipItem(
                  '${rodIndex == 0 ? 'Esperado' : 'Cosechado'}: '
                  '${formatKg(rod.toY)}',
                  const TextStyle(color: Colors.white),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < periods.length; i++)
                BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: expected[i],
                      width: 10,
                      color: expectedColor,
                    ),
                    BarChartRodData(
                      toY: harvested[i],
                      width: 10,
                      color: harvestedColor,
                    ),
                  ],
                ),
            ],
            titlesData: chartTitles(periods.length, (i) => periods[i]),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Wrap(
        spacing: 16,
        children: [
          ChartLegend(color: expectedColor, label: 'Esperado'),
          ChartLegend(color: harvestedColor, label: 'Cosechado'),
        ],
      ),
    ],
  );
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, color: color),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
