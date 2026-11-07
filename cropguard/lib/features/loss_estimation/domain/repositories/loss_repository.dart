import '../entities/loss_estimation.dart';

/// Lanza [Failure] (ver `core/errors/failures.dart`) si algo falla.
abstract class LossRepository {
  Future<LossDefaults> defaults(String plotId);

  /// Calcula sin guardar.
  /// [excludeId]: estimación que se está editando (no cuenta como traslape).
  Future<LossEstimation> preview(
    String plotId,
    LossInput input, {
    String? excludeId,
  });

  Future<LossEstimation> create(String plotId, LossInput input);

  Future<LossPage> list(String plotId, {int limit = 20, int offset = 0});

  Future<LossEstimation> get(String id);

  /// Edita y recalcula en el servidor.
  Future<LossEstimation> update(String id, LossInput input);

  Future<void> delete(String id);
}
