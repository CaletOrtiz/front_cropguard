import 'package:kroppi/core/network/api/services/ai_backend_service.dart';
import 'package:kroppi/features/my_crops/domain/entities/my_crop.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot_sample.dart';

class MyCropsRemoteDataSource {
  MyCropsRemoteDataSource(this._api);

  final AiBackendService _api;

  String _date(DateTime d) => d.toIso8601String().split('T').first;

  // ---------------- Cultivos ----------------

  Future<List<MyCrop>> getCrops() async {
    final r = await _api.send('GET', '/crops') as List;
    return r.map((e) => MyCrop.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Catálogo para el selector del formulario: [{id, name, slug, ...}]
  Future<List<Map<String, dynamic>>> getCropTypes() async {
    final r = await _api.send('GET', '/crop-types') as List;
    return r.cast<Map<String, dynamic>>();
  }

  Future<void> createCrop({
    required String cropTypeId,
    required String name,
    DateTime? plantedAt,
    DateTime? expectedHarvestAt,
  }) async {
    await _api.send(
      'POST',
      '/crops',
      data: {
        'crop_type_id': cropTypeId,
        'name': name,
        'planted_at': ?(plantedAt == null ? null : _date(plantedAt)),
        'expected_harvest_at': ?(expectedHarvestAt == null
            ? null
            : _date(expectedHarvestAt)),
      },
    );
  }

  Future<void> archiveCrop(String cropId) async {
    await _api.send('DELETE', '/crops/$cropId');
  }

  // ---------------- Lotes ----------------

  Future<List<Plot>> getPlots(String cropId) async {
    final r = await _api.send('GET', '/crops/$cropId/plots') as List;
    return r.map((e) => Plot.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createPlot(
    String cropId, {
    required String name,
    required double areaHa,
    int? plantCount,
    String? variety,
  }) async {
    await _api.send(
      'POST',
      '/crops/$cropId/plots',
      data: {
        'name': name,
        'area_ha': areaHa,
        'plant_count': ?plantCount,
        'variety': ?((variety == null || variety.isEmpty) ? null : variety),
      },
    );
  }

  Future<PlotDetail> getPlotDetail(String plotId) async {
    final r = await _api.send('GET', '/plots/$plotId');
    return PlotDetail.fromJson(r as Map<String, dynamic>);
  }

  // ---------------- Muestreos ----------------

  Future<SampleResult> closeSample(
    String plotId,
    List<String> diagnosticIds,
  ) async {
    final r = await _api.send(
      'POST',
      '/plots/$plotId/samples',
      data: {'diagnostic_ids': diagnosticIds},
    );
    return SampleResult.fromJson(r as Map<String, dynamic>);
  }

  Future<List<PlotSample>> getSamples(String plotId) async {
    final r = await _api.send('GET', '/plots/$plotId/samples') as List;
    return r
        .map((e) => PlotSample.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
