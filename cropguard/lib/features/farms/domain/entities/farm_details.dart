import 'package:equatable/equatable.dart';
import 'package:kroppi/features/farms/domain/entities/farm.dart';

enum FarmPlotHealth {
  healthy,
  alert,
  danger;

  static FarmPlotHealth parse(String? value) => switch (value?.toUpperCase()) {
    'ALERT' => alert,
    'DANGER' => danger,
    _ => healthy,
  };
}

class FarmPlot extends Equatable {
  const FarmPlot({
    required this.id,
    required this.cropId,
    required this.name,
    required this.areaHa,
    required this.health,
    this.plantCount,
    this.variety,
    this.lastSampledAt,
  });

  final String id;
  final String cropId;
  final String name;
  final double areaHa;
  final FarmPlotHealth health;
  final int? plantCount;
  final String? variety;
  final DateTime? lastSampledAt;

  @override
  List<Object?> get props => [
    id,
    cropId,
    name,
    areaHa,
    health,
    plantCount,
    variety,
    lastSampledAt,
  ];
}

class FarmCrop extends Equatable {
  const FarmCrop({
    required this.id,
    required this.farmId,
    required this.cropTypeId,
    required this.name,
    required this.typeName,
    required this.isActive,
    this.typeSlug,
    this.plantedAt,
    this.expectedHarvestAt,
    this.plots = const [],
  });

  final String id;
  final String farmId;
  final String cropTypeId;
  final String name;
  final String typeName;
  final String? typeSlug;
  final bool isActive;
  final DateTime? plantedAt;
  final DateTime? expectedHarvestAt;
  final List<FarmPlot> plots;

  double get totalPlotAreaHa =>
      plots.fold(0, (total, plot) => total + plot.areaHa);

  @override
  List<Object?> get props => [
    id,
    farmId,
    cropTypeId,
    name,
    typeName,
    typeSlug,
    isActive,
    plantedAt,
    expectedHarvestAt,
    plots,
  ];
}

class FarmDetails extends Equatable {
  const FarmDetails({required this.farm, required this.crops});

  final Farm farm;
  final List<FarmCrop> crops;

  int get totalPlots =>
      crops.fold(0, (total, crop) => total + crop.plots.length);

  double get totalPlotAreaHa =>
      crops.fold(0, (total, crop) => total + crop.totalPlotAreaHa);

  @override
  List<Object?> get props => [farm, crops];
}
