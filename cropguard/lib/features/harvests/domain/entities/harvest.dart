import 'package:equatable/equatable.dart';
import 'package:kroppi/core/utils/number_format.dart';

class Harvest extends Equatable {
  const Harvest({
    required this.id,
    required this.plotId,
    required this.harvestedAt,
    required this.quantityKg,
    this.pricePerKg,
    this.currency = 'COP',
    this.value,
    this.notes,
  });

  final String id;
  final String plotId;
  final DateTime harvestedAt;
  final double quantityKg;
  final double? pricePerKg;
  final String currency;

  /// kg × precio, calculado por el backend (null sin precio).
  final double? value;
  final String? notes;

  factory Harvest.fromJson(Map<String, dynamic> json) => Harvest(
    id: json['id'] as String,
    plotId: json['plot_id'] as String? ?? '',
    harvestedAt: parseApiDate(json['harvested_at'] as String),
    quantityKg: toDouble(json['quantity_kg']) ?? 0,
    pricePerKg: toDouble(json['price_per_kg']),
    currency: json['currency'] as String? ?? 'COP',
    value: toDouble(json['value']),
    notes: json['notes'] as String?,
  );

  @override
  List<Object?> get props => [
    id,
    plotId,
    harvestedAt,
    quantityKg,
    pricePerKg,
    currency,
    value,
    notes,
  ];
}

class CurrencyRevenue extends Equatable {
  const CurrencyRevenue({
    required this.currency,
    required this.revenue,
    required this.harvestsWithPrice,
  });

  final String currency;
  final double revenue;
  final int harvestsWithPrice;

  factory CurrencyRevenue.fromJson(Map<String, dynamic> json) =>
      CurrencyRevenue(
        currency: json['currency'] as String? ?? 'COP',
        revenue: toDouble(json['revenue']) ?? 0,
        harvestsWithPrice: (json['harvests_with_price'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [currency, revenue, harvestsWithPrice];
}

class HarvestTotals extends Equatable {
  const HarvestTotals({
    this.quantityKg = 0,
    this.byCurrency = const [],
    this.harvestsWithoutPrice = 0,
  });

  final double quantityKg;

  /// Ingresos por moneda: nunca se suman monedas distintas.
  final List<CurrencyRevenue> byCurrency;
  final int harvestsWithoutPrice;

  factory HarvestTotals.fromJson(Map<String, dynamic>? json) => json == null
      ? const HarvestTotals()
      : HarvestTotals(
          quantityKg: toDouble(json['quantity_kg']) ?? 0,
          byCurrency: [
            for (final row in (json['by_currency'] as List? ?? const []))
              CurrencyRevenue.fromJson(row as Map<String, dynamic>),
          ],
          harvestsWithoutPrice:
              (json['harvests_without_price'] as num?)?.toInt() ?? 0,
        );

  @override
  List<Object?> get props => [quantityKg, byCurrency, harvestsWithoutPrice];
}

class HarvestPage extends Equatable {
  const HarvestPage({
    required this.items,
    required this.totals,
    this.nextOffset,
  });

  final List<Harvest> items;
  final HarvestTotals totals;
  final int? nextOffset;

  factory HarvestPage.fromJson(Map<String, dynamic> json) => HarvestPage(
    items: [
      for (final row in (json['items'] as List? ?? const []))
        Harvest.fromJson(row as Map<String, dynamic>),
    ],
    totals: HarvestTotals.fromJson(json['totals'] as Map<String, dynamic>?),
    nextOffset: (json['next_offset'] as num?)?.toInt(),
  );

  @override
  List<Object?> get props => [items, totals, nextOffset];
}

/// Datos que envía el formulario (crear o editar).
class HarvestInput extends Equatable {
  const HarvestInput({
    required this.harvestedAt,
    required this.quantityKg,
    this.pricePerKg,
    this.currency = 'COP',
    this.notes,
  });

  final DateTime harvestedAt;
  final double quantityKg;
  final double? pricePerKg;
  final String currency;
  final String? notes;

  Map<String, dynamic> toJson() {
    final note = notes?.trim();
    return {
      'harvested_at': apiDate(harvestedAt),
      'quantity_kg': quantityKg,
      'price_per_kg': pricePerKg,
      'currency': currency,
      'notes': note == null || note.isEmpty ? null : note,
    };
  }

  @override
  List<Object?> get props => [
    harvestedAt,
    quantityKg,
    pricePerKg,
    currency,
    notes,
  ];
}

/// Respuesta de crear/editar: la cosecha y las estimaciones de pérdida cuyo
/// periodo la contiene (para sugerir recalcularlas).
class HarvestSaveResult extends Equatable {
  const HarvestSaveResult({
    required this.harvest,
    this.affectsEstimations = const [],
  });

  final Harvest harvest;
  final List<String> affectsEstimations;

  factory HarvestSaveResult.fromJson(Map<String, dynamic> json) =>
      HarvestSaveResult(
        harvest: Harvest.fromJson(json),
        affectsEstimations: [
          for (final id in (json['affects_estimations'] as List? ?? const []))
            id.toString(),
        ],
      );

  @override
  List<Object?> get props => [harvest, affectsEstimations];
}
