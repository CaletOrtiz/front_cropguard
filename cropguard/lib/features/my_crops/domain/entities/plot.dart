import 'package:equatable/equatable.dart';

enum PlotStatus {
  healthy,
  alert,
  danger;

  static PlotStatus parse(String? v) => switch (v) {
    'DANGER' => danger,
    'ALERT' => alert,
    _ => healthy,
  };
}

class Plot extends Equatable {
  const Plot({
    required this.id,
    required this.cropId,
    required this.name,
    required this.areaHa,
    required this.status,
    this.plantCount,
    this.variety,
    this.lastSampledAt,
  });

  final String id;
  final String cropId;
  final String name;
  final double areaHa;
  final int? plantCount;
  final String? variety;
  final PlotStatus status;
  final DateTime? lastSampledAt;

  factory Plot.fromJson(Map<String, dynamic> j) => Plot(
    id: j['id'] as String,
    cropId: j['crop_id'] as String,
    name: j['name'] as String,
    areaHa: (j['area_ha'] as num).toDouble(),
    plantCount: j['plant_count'] as int?,
    variety: j['variety'] as String?,
    status: PlotStatus.parse(j['status'] as String?),
    lastSampledAt: j['last_sampled_at'] == null
        ? null
        : DateTime.tryParse(j['last_sampled_at'] as String)?.toLocal(),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    areaHa,
    plantCount,
    variety,
    status,
    lastSampledAt,
  ];
}

/// Respuesta de GET /plots/{id}: el lote más datos de su cultivo y umbrales.
class PlotDetail extends Equatable {
  const PlotDetail({
    required this.plot,
    required this.cropName,
    required this.cropSlug,
    required this.alertPct,
    required this.dangerPct,
    this.lastIncidencePct,
  });

  final Plot plot;
  final String cropName;
  final String cropSlug;
  final double alertPct;
  final double dangerPct;
  final double? lastIncidencePct;

  factory PlotDetail.fromJson(Map<String, dynamic> j) {
    final type = j['crop_type'] as Map<String, dynamic>;
    final crop = j['crop'] as Map<String, dynamic>;
    final last = j['last_sample'] as Map<String, dynamic>?;
    return PlotDetail(
      plot: Plot.fromJson(j),
      cropName: crop['name'] as String,
      cropSlug: (type['slug'] as String?) ?? 'cafe',
      alertPct: (type['alert_threshold_pct'] as num).toDouble(),
      dangerPct: (type['danger_threshold_pct'] as num).toDouble(),
      lastIncidencePct: (last?['incidence_pct'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    plot,
    cropName,
    cropSlug,
    alertPct,
    dangerPct,
    lastIncidencePct,
  ];
}
