import 'package:equatable/equatable.dart';
import 'plot.dart';

/// Resultado de cerrar un muestreo (PATCH /samples/{id}).
class SampleResult extends Equatable {
  const SampleResult({
    required this.evaluated,
    required this.affected,
    required this.discarded,
    required this.incidencePct,
    required this.status,
  });

  SampleResult copyWith({int? discarded}) => SampleResult(
    evaluated: evaluated,
    affected: affected,
    discarded: discarded ?? this.discarded,
    incidencePct: incidencePct,
    status: status,
  );

  final int evaluated;
  final int affected;
  final int discarded;
  final double incidencePct;
  final PlotStatus status;

  factory SampleResult.fromJson(Map<String, dynamic> j) => SampleResult(
    evaluated: j['plants_evaluated'] as int,
    affected: j['plants_affected'] as int,
    discarded: (j['discarded'] as int?) ?? 0,
    incidencePct: (j['incidence_pct'] as num).toDouble(),
    status: PlotStatus.parse(j['status'] as String?),
  );

  @override
  List<Object?> get props => [
    evaluated,
    affected,
    discarded,
    incidencePct,
    status,
  ];
}

/// Un punto del historial (GET /plots/{id}/samples), para la gráfica.
class PlotSample extends Equatable {
  const PlotSample({
    required this.sampledAt,
    required this.evaluated,
    required this.affected,
    required this.incidencePct,
  });

  final DateTime sampledAt;
  final int evaluated;
  final int affected;
  final double incidencePct;

  factory PlotSample.fromJson(Map<String, dynamic> j) => PlotSample(
    sampledAt: DateTime.parse(j['sampled_at'] as String).toLocal(),
    evaluated: j['plants_evaluated'] as int,
    affected: j['plants_affected'] as int,
    incidencePct: (j['incidence_pct'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [sampledAt, evaluated, affected, incidencePct];
}
