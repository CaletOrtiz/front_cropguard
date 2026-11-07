import '../entities/harvest.dart';

/// Lanza [Failure] (ver `core/errors/failures.dart`) si algo falla.
abstract class HarvestRepository {
  Future<HarvestPage> list(
    String plotId, {
    DateTime? from,
    DateTime? to,
    int limit = 20,
    int offset = 0,
  });

  Future<Harvest> get(String id);

  Future<HarvestSaveResult> create(String plotId, HarvestInput input);

  Future<HarvestSaveResult> update(String id, HarvestInput input);

  Future<void> delete(String id);
}
