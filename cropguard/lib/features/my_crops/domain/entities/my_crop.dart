import 'package:equatable/equatable.dart';

class MyCrop extends Equatable {
  const MyCrop({
    required this.id,
    required this.name,
    required this.typeId,
    required this.typeName,
    required this.typeSlug,
    required this.totalPlots,
    required this.alertPlots,
    required this.dangerPlots,
    required this.totalAreaHa,
  });

  final String id;
  final String name;
  final String typeId;
  final String typeName;
  final String typeSlug;
  final int totalPlots;
  final int alertPlots;
  final int dangerPlots;
  final double totalAreaHa;

  factory MyCrop.fromJson(Map<String, dynamic> j) {
    final t = j['crop_type'] as Map<String, dynamic>;
    final s = j['plots_summary'] as Map<String, dynamic>;
    return MyCrop(
      id: j['id'] as String,
      name: j['name'] as String,
      typeId: t['id'] as String,
      typeName: t['name'] as String,
      typeSlug: (t['slug'] as String?) ?? '',
      totalPlots: s['total'] as int,
      alertPlots: s['alert'] as int,
      dangerPlots: s['danger'] as int,
      totalAreaHa: (s['total_area_ha'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    typeId,
    totalPlots,
    alertPlots,
    dangerPlots,
    totalAreaHa,
  ];
}
