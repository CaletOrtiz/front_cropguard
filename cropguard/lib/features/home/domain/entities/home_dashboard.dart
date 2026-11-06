import 'package:equatable/equatable.dart';
import 'package:kroppi/features/farms/domain/entities/farm.dart';

class HomeDashboard extends Equatable {
  const HomeDashboard({required this.farms, required this.pendingSamplings});

  final List<Farm> farms;
  final List<HomePendingSampling> pendingSamplings;

  int get totalFarms => farms.length;

  int get totalPlots => farms.fold(0, (total, farm) => total + farm.plotCount);

  int get alertPlots => farms.fold(0, (total, farm) => total + farm.alertPlots);

  int get dangerPlots =>
      farms.fold(0, (total, farm) => total + farm.dangerPlots);

  bool get isEmpty => farms.isEmpty;

  @override
  List<Object?> get props => [farms, pendingSamplings];
}

class HomePendingSampling extends Equatable {
  const HomePendingSampling({
    required this.plotId,
    required this.plotName,
    required this.farmName,
    this.cropSlug = 'cafe',
    this.plantCount,
    this.lastSampledAt,
  });

  final String plotId;
  final String plotName;
  final String farmName;
  final String cropSlug;
  final int? plantCount;
  final DateTime? lastSampledAt;

  bool get hasNeverBeenSampled => lastSampledAt == null;

  int? get daysSinceLastSample => lastSampledAt == null
      ? null
      : DateTime.now().difference(lastSampledAt!).inDays;

  @override
  List<Object?> get props => [
    plotId,
    plotName,
    farmName,
    cropSlug,
    plantCount,
    lastSampledAt,
  ];
}
