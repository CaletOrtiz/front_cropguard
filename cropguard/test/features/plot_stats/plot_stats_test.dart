import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/plot_stats/domain/entities/plot_stats.dart';

void main() {
  test('stats vacías o con campos nulos no fallan', () {
    final stats = PlotStats.fromJson({
      'thresholds': {'alert_pct': 5, 'danger_pct': 15},
      'incidence_series': [],
      'harvest_series': [],
      'totals': {'loss_pct_overall': null},
    });
    expect(stats.currency, 'COP');
    expect(stats.mixedCurrency, isFalse);
    expect(stats.excludedOtherCurrency, isNull);
    expect(stats.expectedVsHarvested, isEmpty);
    expect(stats.totals.lossPctOverall, isNull);
    expect(stats.totals.revenue, 0);
  });

  test('lee las series monetarias y la moneda', () {
    final stats = PlotStats.fromJson({
      'currency': 'USD',
      'mixed_currency': true,
      'excluded_other_currency': {'count': 2, 'currency': 'COP'},
      'harvest_series': [
        {'period': '2026-10', 'kg': 850, 'revenue': null},
      ],
      'income_series': [
        {'period': '2026-10', 'revenue': 100, 'cumulative_revenue': 100},
      ],
      'loss_series': [
        {
          'period': '2026-10',
          'lost_kg': 300,
          'loss_amount': 50,
          'cumulative_loss_amount': 50,
        },
      ],
      'expected_vs_harvested': [
        {'period': '2026-10', 'expected_kg': 1200, 'harvested_kg': 900},
      ],
      'totals': {
        'expected_kg': 1200,
        'lost_kg': 300,
        'loss_pct_overall': 25,
        'care_cost_cop': 1000,
      },
    });
    expect(stats.currency, 'USD');
    expect(stats.excludedOtherCurrency!.count, 2);
    expect(stats.harvestSeries.single.revenue, isNull);
    expect(stats.lossSeries.single.cumulativeLossAmount, 50);
    expect(stats.expectedVsHarvested.single.expectedKg, 1200);
    expect(stats.totals.lossPctOverall, 25);
  });
}
