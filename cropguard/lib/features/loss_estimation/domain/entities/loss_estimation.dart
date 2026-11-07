import 'package:equatable/equatable.dart';
import 'package:kroppi/core/utils/number_format.dart';

/// Estimación de pérdidas (guardada o resultado de un preview, con id null).
/// Todas las cifras vienen calculadas por el backend.
class LossEstimation extends Equatable {
  const LossEstimation({
    this.id,
    required this.plotId,
    required this.expectedYieldKg,
    required this.harvestedKg,
    required this.lostKg,
    required this.lossPct,
    this.surplusKg = 0,
    required this.pricePerKg,
    this.currency = 'COP',
    required this.estimatedLossAmount,
    required this.periodFrom,
    required this.periodTo,
    this.explanation,
    this.notes,
    this.warnings = const [],
    this.harvestsInPeriod = 0,
    this.createdAt,
  });

  final String? id;
  final String plotId;
  final double expectedYieldKg;
  final double harvestedKg;
  final double lostKg;
  final double lossPct;
  final double surplusKg;
  final double pricePerKg;
  final String currency;
  final double estimatedLossAmount;
  final DateTime periodFrom;
  final DateTime periodTo;
  final String? explanation;
  final String? notes;
  final List<String> warnings;
  final int harvestsInPeriod;
  final DateTime? createdAt;

  bool get hasLoss => lostKg > 0;

  factory LossEstimation.fromJson(Map<String, dynamic> json) => LossEstimation(
    id: json['id'] as String?,
    plotId: json['plot_id'] as String? ?? '',
    expectedYieldKg: toDouble(json['expected_yield_kg']) ?? 0,
    harvestedKg: toDouble(json['harvested_kg']) ?? 0,
    lostKg: toDouble(json['lost_kg']) ?? 0,
    lossPct: toDouble(json['loss_pct']) ?? 0,
    surplusKg: toDouble(json['surplus_kg']) ?? 0,
    pricePerKg: toDouble(json['price_per_kg']) ?? 0,
    currency: json['currency'] as String? ?? 'COP',
    estimatedLossAmount: toDouble(json['estimated_loss_amount']) ?? 0,
    periodFrom: parseApiDate(json['period_from'] as String),
    periodTo: parseApiDate(json['period_to'] as String),
    explanation: json['explanation'] as String?,
    notes: json['notes'] as String?,
    warnings: [
      for (final warning in (json['warnings'] as List? ?? const []))
        warning.toString(),
    ],
    harvestsInPeriod: (json['harvests_in_period'] as num?)?.toInt() ?? 0,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String)?.toLocal(),
  );

  @override
  List<Object?> get props => [
    id,
    plotId,
    expectedYieldKg,
    harvestedKg,
    lostKg,
    lossPct,
    surplusKg,
    pricePerKg,
    currency,
    estimatedLossAmount,
    periodFrom,
    periodTo,
    explanation,
    notes,
    warnings,
    harvestsInPeriod,
    createdAt,
  ];
}

/// Valores sugeridos para prellenar el formulario.
class LossDefaults extends Equatable {
  const LossDefaults({
    this.expectedYieldKg,
    this.expectedYieldSource,
    this.pricePerKg,
    this.priceSource,
    this.currency = 'COP',
    required this.periodFrom,
    required this.periodTo,
  });

  final double? expectedYieldKg;
  final String? expectedYieldSource;
  final double? pricePerKg;
  final String? priceSource;
  final String currency;
  final DateTime periodFrom;
  final DateTime periodTo;

  factory LossDefaults.fromJson(Map<String, dynamic> json) => LossDefaults(
    expectedYieldKg: toDouble(json['expected_yield_kg']),
    expectedYieldSource: json['expected_yield_source'] as String?,
    pricePerKg: toDouble(json['price_per_kg']),
    priceSource: json['price_source'] as String?,
    currency: json['currency'] as String? ?? 'COP',
    periodFrom: parseApiDate(json['period_from'] as String),
    periodTo: parseApiDate(json['period_to'] as String),
  );

  @override
  List<Object?> get props => [
    expectedYieldKg,
    expectedYieldSource,
    pricePerKg,
    priceSource,
    currency,
    periodFrom,
    periodTo,
  ];
}

/// Entradas del agricultor (crear, editar o previsualizar).
class LossInput extends Equatable {
  const LossInput({
    required this.expectedYieldKg,
    required this.pricePerKg,
    required this.currency,
    required this.periodFrom,
    required this.periodTo,
    this.notes,
  });

  final double expectedYieldKg;
  final double pricePerKg;
  final String currency;
  final DateTime periodFrom;
  final DateTime periodTo;
  final String? notes;

  Map<String, dynamic> toJson() {
    final note = notes?.trim();
    return {
      'expected_yield_kg': expectedYieldKg,
      'price_per_kg': pricePerKg,
      'currency': currency,
      'period_from': apiDate(periodFrom),
      'period_to': apiDate(periodTo),
      'notes': note == null || note.isEmpty ? null : note,
    };
  }

  @override
  List<Object?> get props => [
    expectedYieldKg,
    pricePerKg,
    currency,
    periodFrom,
    periodTo,
    notes,
  ];
}

class LossPage extends Equatable {
  const LossPage({required this.items, this.nextOffset});

  final List<LossEstimation> items;
  final int? nextOffset;

  factory LossPage.fromJson(Map<String, dynamic> json) => LossPage(
    items: [
      for (final row in (json['items'] as List? ?? const []))
        LossEstimation.fromJson(row as Map<String, dynamic>),
    ],
    nextOffset: (json['next_offset'] as num?)?.toInt(),
  );

  @override
  List<Object?> get props => [items, nextOffset];
}
