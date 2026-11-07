import 'package:kroppi/core/utils/number_format.dart';

/// Respuesta de GET /plots/{id}/stats. Los montos están en [currency]; los de
/// otra moneda los excluye el backend (ver [excludedOtherCurrency]).
class PlotStats {
  const PlotStats({
    required this.currency,
    required this.mixedCurrency,
    this.excludedOtherCurrency,
    required this.alertPct,
    required this.dangerPct,
    required this.incidenceSeries,
    required this.healthEvolution,
    required this.diseaseBreakdown,
    required this.harvestSeries,
    required this.incomeSeries,
    required this.lossSeries,
    required this.expectedVsHarvested,
    required this.harvestsWithoutPrice,
    required this.totals,
  });

  final String currency;
  final bool mixedCurrency;
  final ExcludedCurrency? excludedOtherCurrency;
  final double alertPct;
  final double dangerPct;
  final List<IncidencePoint> incidenceSeries;
  final List<Map<String, dynamic>> healthEvolution;
  final List<Map<String, dynamic>> diseaseBreakdown;
  final List<HarvestPoint> harvestSeries;
  final List<IncomePoint> incomeSeries;
  final List<LossPoint> lossSeries;
  final List<ExpectedVsHarvestedPoint> expectedVsHarvested;
  final int harvestsWithoutPrice;
  final StatsTotals totals;

  static List<Map<String, dynamic>> _rows(Object? value) =>
      (value as List? ?? const []).cast<Map<String, dynamic>>();

  factory PlotStats.fromJson(Map<String, dynamic> json) {
    final thresholds = json['thresholds'] as Map<String, dynamic>? ?? const {};
    final excluded = json['excluded_other_currency'] as Map<String, dynamic>?;
    return PlotStats(
      currency: json['currency'] as String? ?? 'COP',
      mixedCurrency: json['mixed_currency'] as bool? ?? false,
      excludedOtherCurrency: excluded == null
          ? null
          : ExcludedCurrency.fromJson(excluded),
      alertPct: toDouble(thresholds['alert_pct']) ?? 0,
      dangerPct: toDouble(thresholds['danger_pct']) ?? 0,
      incidenceSeries: _rows(
        json['incidence_series'],
      ).map(IncidencePoint.fromJson).toList(),
      healthEvolution: _rows(json['health_evolution']),
      diseaseBreakdown: _rows(json['disease_breakdown']),
      harvestSeries: _rows(
        json['harvest_series'],
      ).map(HarvestPoint.fromJson).toList(),
      incomeSeries: _rows(
        json['income_series'],
      ).map(IncomePoint.fromJson).toList(),
      lossSeries: _rows(json['loss_series']).map(LossPoint.fromJson).toList(),
      expectedVsHarvested: _rows(
        json['expected_vs_harvested'],
      ).map(ExpectedVsHarvestedPoint.fromJson).toList(),
      harvestsWithoutPrice:
          (json['harvests_without_price'] as num?)?.toInt() ?? 0,
      totals: StatsTotals.fromJson(
        json['totals'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ExcludedCurrency {
  const ExcludedCurrency({required this.count, required this.currency});

  final int count;
  final String currency;

  factory ExcludedCurrency.fromJson(Map<String, dynamic> json) =>
      ExcludedCurrency(
        count: (json['count'] as num?)?.toInt() ?? 0,
        currency: json['currency'] as String? ?? '',
      );
}

class IncidencePoint {
  const IncidencePoint({
    required this.sampledAt,
    required this.incidencePct,
    required this.plantsAffected,
  });

  final DateTime? sampledAt;
  final double incidencePct;
  final int plantsAffected;

  factory IncidencePoint.fromJson(Map<String, dynamic> json) => IncidencePoint(
    sampledAt: DateTime.tryParse(
      json['sampled_at'] as String? ?? '',
    )?.toLocal(),
    incidencePct: toDouble(json['incidence_pct']) ?? 0,
    plantsAffected: (json['plants_affected'] as num?)?.toInt() ?? 0,
  );
}

class HarvestPoint {
  const HarvestPoint({required this.period, required this.kg, this.revenue});

  final String period;
  final double kg;
  final double? revenue;

  factory HarvestPoint.fromJson(Map<String, dynamic> json) => HarvestPoint(
    period: json['period'].toString(),
    kg: toDouble(json['kg']) ?? 0,
    revenue: toDouble(json['revenue']),
  );
}

class IncomePoint {
  const IncomePoint({
    required this.period,
    required this.revenue,
    required this.cumulativeRevenue,
  });

  final String period;
  final double revenue;
  final double cumulativeRevenue;

  factory IncomePoint.fromJson(Map<String, dynamic> json) => IncomePoint(
    period: json['period'].toString(),
    revenue: toDouble(json['revenue']) ?? 0,
    cumulativeRevenue: toDouble(json['cumulative_revenue']) ?? 0,
  );
}

class LossPoint {
  const LossPoint({
    required this.period,
    required this.lostKg,
    required this.lossAmount,
    required this.cumulativeLossAmount,
  });

  final String period;
  final double lostKg;
  final double lossAmount;
  final double cumulativeLossAmount;

  factory LossPoint.fromJson(Map<String, dynamic> json) => LossPoint(
    period: json['period'].toString(),
    lostKg: toDouble(json['lost_kg']) ?? 0,
    lossAmount: toDouble(json['loss_amount']) ?? 0,
    cumulativeLossAmount: toDouble(json['cumulative_loss_amount']) ?? 0,
  );
}

class ExpectedVsHarvestedPoint {
  const ExpectedVsHarvestedPoint({
    required this.period,
    required this.expectedKg,
    required this.harvestedKg,
  });

  final String period;
  final double expectedKg;
  final double harvestedKg;

  factory ExpectedVsHarvestedPoint.fromJson(Map<String, dynamic> json) =>
      ExpectedVsHarvestedPoint(
        period: json['period'].toString(),
        expectedKg: toDouble(json['expected_kg']) ?? 0,
        harvestedKg: toDouble(json['harvested_kg']) ?? 0,
      );
}

class StatsTotals {
  const StatsTotals({
    this.samples = 0,
    this.avgIncidencePct = 0,
    this.maxIncidencePct = 0,
    this.harvestedKg = 0,
    this.revenue = 0,
    this.lossAmount = 0,
    this.careCostCop = 0,
    this.expectedKg = 0,
    this.lostKg = 0,
    this.lossPctOverall,
  });

  final int samples;
  final double avgIncidencePct;
  final double maxIncidencePct;
  final double harvestedKg;
  final double revenue;
  final double lossAmount;

  /// Siempre en COP.
  final double careCostCop;
  final double expectedKg;
  final double lostKg;

  /// Null si no hay kilos esperados.
  final double? lossPctOverall;

  factory StatsTotals.fromJson(Map<String, dynamic> json) => StatsTotals(
    samples: (json['samples'] as num?)?.toInt() ?? 0,
    avgIncidencePct: toDouble(json['avg_incidence_pct']) ?? 0,
    maxIncidencePct: toDouble(json['max_incidence_pct']) ?? 0,
    harvestedKg: toDouble(json['harvested_kg']) ?? 0,
    revenue: toDouble(json['revenue']) ?? 0,
    lossAmount: toDouble(json['loss_amount']) ?? 0,
    careCostCop: toDouble(json['care_cost_cop']) ?? 0,
    expectedKg: toDouble(json['expected_kg']) ?? 0,
    lostKg: toDouble(json['lost_kg']) ?? 0,
    lossPctOverall: toDouble(json['loss_pct_overall']),
  );
}
