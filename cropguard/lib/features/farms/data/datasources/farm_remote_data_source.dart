import 'package:kroppi/features/farms/domain/entities/farm.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/features/home/domain/entities/home_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmRemoteDataSource {
  FarmRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<void> createFarm({
    required String name,
    required double areaHa,
    String? description,
    String? department,
    String? municipality,
    String? address,
  }) async {
    final userId = _requireUserId();
    await _client.from('farms').insert({
      'owner_id': userId,
      'name': name.trim(),
      'area_ha': areaHa,
      'description': ?_optionalText(description),
      'department': ?_optionalText(department),
      'municipality': ?_optionalText(municipality),
      'address': ?_optionalText(address),
    });
  }

  Future<void> updateFarm({
    required String farmId,
    required String name,
    required double areaHa,
    String? description,
    String? department,
    String? municipality,
    String? address,
  }) async {
    final userId = _requireUserId();
    await _client
        .from('farms')
        .update({
          'name': name.trim(),
          'area_ha': areaHa,
          'description': ?_optionalText(description),
          'department': ?_optionalText(department),
          'municipality': ?_optionalText(municipality),
          'address': ?_optionalText(address),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', farmId)
        .eq('owner_id', userId);
  }

  Future<Farm> getFarm(String farmId) async {
    final userId = _requireUserId();
    final row = await _client
        .from('farms')
        .select(
          'id, name, description, department, municipality, address, '
          'area_ha, created_at',
        )
        .eq('id', farmId)
        .eq('owner_id', userId)
        .maybeSingle();
    if (row == null) throw StateError('No se encontró la finca.');
    return _farmFromRow(row);
  }

  Future<List<Farm>> getFarms() async => (await _loadSnapshot()).farms;

  Future<FarmDetails> getFarmDetails(String farmId) async {
    final farm = await getFarm(farmId);
    final cropRows = _asRows(
      await _client
          .from('crops')
          .select(
            'id, farm_id, crop_type_id, name, planted_at, '
            'expected_harvest_at, is_active, created_at',
          )
          .eq('farm_id', farmId)
          .order('created_at', ascending: false),
    );
    if (cropRows.isEmpty) return FarmDetails(farm: farm, crops: const []);

    final cropTypeIds = cropRows
        .map((crop) => crop['crop_type_id'] as String)
        .toSet()
        .toList();
    final typeRows = _asRows(
      await _client
          .from('crop_types')
          .select('id, name, slug')
          .inFilter('id', cropTypeIds),
    );
    final typesById = {for (final type in typeRows) type['id'] as String: type};
    final cropIds = cropRows.map((crop) => crop['id'] as String).toList();
    final plotRows = _asRows(
      await _client
          .from('plots')
          .select(
            'id, crop_id, name, area_ha, plant_count, variety, status, '
            'last_sampled_at',
          )
          .inFilter('crop_id', cropIds)
          .order('created_at'),
    );
    final plotsByCrop = <String, List<FarmPlot>>{};
    for (final row in plotRows) {
      final plot = _plotFromRow(row);
      plotsByCrop.putIfAbsent(plot.cropId, () => []).add(plot);
    }

    final crops = [
      for (final row in cropRows)
        _cropFromRow(
          row,
          typesById[row['crop_type_id']],
          plotsByCrop[row['id'] as String] ?? const [],
        ),
    ];
    return FarmDetails(farm: farm, crops: crops);
  }

  Future<FarmCrop> getFarmCrop(String cropId) async {
    _requireUserId();
    final row = await _client
        .from('crops')
        .select(
          'id, farm_id, crop_type_id, name, planted_at, '
          'expected_harvest_at, is_active, created_at',
        )
        .eq('id', cropId)
        .maybeSingle();
    if (row == null) throw StateError('No se encontró el cultivo.');
    final type = await _client
        .from('crop_types')
        .select('id, name, slug')
        .eq('id', row['crop_type_id'] as String)
        .maybeSingle();
    final plotRows = _asRows(
      await _client
          .from('plots')
          .select(
            'id, crop_id, name, area_ha, plant_count, variety, status, '
            'last_sampled_at',
          )
          .eq('crop_id', cropId)
          .order('created_at'),
    );
    return _cropFromRow(
      row,
      type == null ? null : Map<String, dynamic>.from(type),
      plotRows.map(_plotFromRow).toList(),
    );
  }

  Future<FarmPlot> getFarmPlot(String plotId) async {
    _requireUserId();
    final row = await _client
        .from('plots')
        .select(
          'id, crop_id, name, area_ha, plant_count, variety, status, '
          'last_sampled_at',
        )
        .eq('id', plotId)
        .maybeSingle();
    if (row == null) throw StateError('No se encontró el lote.');
    return _plotFromRow(Map<String, dynamic>.from(row));
  }

  Future<List<Map<String, dynamic>>> getCropTypes() async {
    final rows = _asRows(
      await _client
          .from('crop_types')
          .select('id, name')
          .eq('is_active', true)
          .order('name'),
    );
    return rows;
  }

  Future<void> createCrop({
    required String farmId,
    required String cropTypeId,
    required String name,
    required bool isActive,
    DateTime? plantedAt,
    DateTime? expectedHarvestAt,
  }) async {
    _requireUserId();
    await _client.from('crops').insert({
      'farm_id': farmId,
      'crop_type_id': cropTypeId,
      'name': name.trim(),
      'is_active': isActive,
      'planted_at': ?_date(plantedAt),
      'expected_harvest_at': ?_date(expectedHarvestAt),
    });
  }

  Future<void> updateCrop({
    required String cropId,
    required String cropTypeId,
    required String name,
    required bool isActive,
    DateTime? plantedAt,
    DateTime? expectedHarvestAt,
  }) async {
    _requireUserId();
    await _client
        .from('crops')
        .update({
          'crop_type_id': cropTypeId,
          'name': name.trim(),
          'is_active': isActive,
          'planted_at': ?_date(plantedAt),
          'expected_harvest_at': ?_date(expectedHarvestAt),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', cropId);
  }

  Future<void> createFarmPlot({
    required String cropId,
    required String name,
    required double areaHa,
    int? plantCount,
    String? variety,
  }) async {
    _requireUserId();
    await _client.from('plots').insert({
      'crop_id': cropId,
      'name': name.trim(),
      'area_ha': areaHa,
      'plant_count': ?plantCount,
      'variety': ?_optionalText(variety),
    });
  }

  Future<HomeDashboard> getDashboard() async {
    final snapshot = await _loadSnapshot();
    return HomeDashboard(
      farms: snapshot.farms,
      pendingSamplings: snapshot.pendingSamplings,
    );
  }

  Future<_FarmSnapshot> _loadSnapshot() async {
    final userId = _requireUserId();
    final farmRows = _asRows(
      await _client
          .from('farms')
          .select(
            'id, name, description, department, municipality, address, '
            'area_ha, created_at',
          )
          .eq('owner_id', userId)
          .order('created_at', ascending: false),
    );
    if (farmRows.isEmpty) return const _FarmSnapshot.empty();

    final farmsById = {for (final farm in farmRows) farm['id'] as String: farm};
    final farmIds = farmsById.keys.toList();
    final cropRows = _asRows(
      await _client
          .from('crops')
          .select('id, farm_id')
          .inFilter('farm_id', farmIds)
          .eq('is_active', true),
    );
    final cropToFarm = <String, String>{};
    final cropsByFarm = <String, int>{};
    for (final crop in cropRows) {
      final cropId = crop['id'] as String;
      final farmId = crop['farm_id'] as String;
      cropToFarm[cropId] = farmId;
      cropsByFarm.update(farmId, (count) => count + 1, ifAbsent: () => 1);
    }

    final plotRows = cropToFarm.isEmpty
        ? <Map<String, dynamic>>[]
        : _asRows(
            await _client
                .from('plots')
                .select('id, crop_id, name, status, last_sampled_at')
                .inFilter('crop_id', cropToFarm.keys.toList()),
          );
    final plotsByFarm = <String, int>{};
    final alertsByFarm = <String, int>{};
    final dangersByFarm = <String, int>{};
    final pendingSamplings = <HomePendingSampling>[];
    final now = DateTime.now();

    for (final plot in plotRows) {
      final farmId = cropToFarm[plot['crop_id']];
      if (farmId == null) continue;

      plotsByFarm.update(farmId, (count) => count + 1, ifAbsent: () => 1);
      switch (plot['status'] as String?) {
        case 'ALERT':
          alertsByFarm.update(farmId, (count) => count + 1, ifAbsent: () => 1);
        case 'DANGER':
          dangersByFarm.update(farmId, (count) => count + 1, ifAbsent: () => 1);
      }

      final sampledAtValue = plot['last_sampled_at'] as String?;
      final sampledAt = sampledAtValue == null
          ? null
          : DateTime.tryParse(sampledAtValue)?.toLocal();
      final needsSampling =
          sampledAt == null ||
          now.difference(sampledAt) > const Duration(days: 7);
      if (needsSampling) {
        pendingSamplings.add(
          HomePendingSampling(
            plotId: plot['id'] as String,
            plotName: plot['name'] as String,
            farmName: farmsById[farmId]!['name'] as String,
            lastSampledAt: sampledAt,
          ),
        );
      }
    }

    final farms = [
      for (final farm in farmRows)
        Farm(
          id: farm['id'] as String,
          name: farm['name'] as String,
          description: farm['description'] as String?,
          department: farm['department'] as String?,
          municipality: farm['municipality'] as String?,
          address: farm['address'] as String?,
          areaHa: (farm['area_ha'] as num?)?.toDouble(),
          cropCount: cropsByFarm[farm['id']] ?? 0,
          plotCount: plotsByFarm[farm['id']] ?? 0,
          alertPlots: alertsByFarm[farm['id']] ?? 0,
          dangerPlots: dangersByFarm[farm['id']] ?? 0,
        ),
    ];

    return _FarmSnapshot(farms: farms, pendingSamplings: pendingSamplings);
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException(
        'Debes iniciar sesión para consultar tus fincas.',
      );
    }
    return userId;
  }

  String? _optionalText(String? value) {
    final text = value?.trim();
    if (text?.isEmpty ?? true) return null;
    return text;
  }

  String? _date(DateTime? value) => value?.toIso8601String().split('T').first;

  Farm _farmFromRow(Map<String, dynamic> row) => Farm(
    id: row['id'] as String,
    name: row['name'] as String,
    description: row['description'] as String?,
    department: row['department'] as String?,
    municipality: row['municipality'] as String?,
    address: row['address'] as String?,
    areaHa: (row['area_ha'] as num?)?.toDouble(),
  );

  FarmCrop _cropFromRow(
    Map<String, dynamic> row,
    Map<String, dynamic>? type,
    List<FarmPlot> plots,
  ) => FarmCrop(
    id: row['id'] as String,
    farmId: row['farm_id'] as String,
    cropTypeId: row['crop_type_id'] as String,
    name: row['name'] as String,
    typeName: type?['name'] as String? ?? 'Cultivo',
    typeSlug: type?['slug'] as String?,
    isActive: row['is_active'] as bool? ?? false,
    plantedAt: _parseDate(row['planted_at']),
    expectedHarvestAt: _parseDate(row['expected_harvest_at']),
    plots: plots,
  );

  FarmPlot _plotFromRow(Map<String, dynamic> row) => FarmPlot(
    id: row['id'] as String,
    cropId: row['crop_id'] as String,
    name: row['name'] as String,
    areaHa: (row['area_ha'] as num).toDouble(),
    health: FarmPlotHealth.parse(row['status'] as String?),
    plantCount: (row['plant_count'] as num?)?.toInt(),
    variety: row['variety'] as String?,
    lastSampledAt: _parseDate(row['last_sampled_at'])?.toLocal(),
  );

  DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.tryParse(value as String);

  List<Map<String, dynamic>> _asRows(List<dynamic> rows) => [
    for (final row in rows) Map<String, dynamic>.from(row as Map),
  ];
}

class _FarmSnapshot {
  const _FarmSnapshot({required this.farms, required this.pendingSamplings});

  const _FarmSnapshot.empty() : farms = const [], pendingSamplings = const [];

  final List<Farm> farms;
  final List<HomePendingSampling> pendingSamplings;
}
