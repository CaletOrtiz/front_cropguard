import 'package:equatable/equatable.dart';

class Farm extends Equatable {
  const Farm({
    required this.id,
    required this.name,
    this.description,
    this.department,
    this.municipality,
    this.address,
    this.areaHa,
    this.cropCount = 0,
    this.plotCount = 0,
    this.alertPlots = 0,
    this.dangerPlots = 0,
  });

  final String id;
  final String name;
  final String? description;
  final String? department;
  final String? municipality;
  final String? address;
  final double? areaHa;
  final int cropCount;
  final int plotCount;
  final int alertPlots;
  final int dangerPlots;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    department,
    municipality,
    address,
    areaHa,
    cropCount,
    plotCount,
    alertPlots,
    dangerPlots,
  ];
}
