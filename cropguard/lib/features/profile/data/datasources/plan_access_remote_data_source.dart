import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/plan_catalog.dart';

class PlanAccessRemoteDataSource {
  const PlanAccessRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<void> ensureCanCreateFarm() async {
    final plan = await _getPlan();
    if (plan.isPremium) return;

    final count = await _client
        .from('farms')
        .count()
        .eq('owner_id', plan.userId);
    _ensureBelowLimit(
      count: count,
      limit: PlanCatalog.freeFarmLimit,
      resource: 'finca',
      isPremium: false,
    );
  }

  Future<void> ensureCanCreateCrop() async {
    final plan = await _getPlan();
    if (plan.isPremium) return;

    final response = await _client
        .from('crops')
        .select('id, farms!inner(owner_id)')
        .eq('farms.owner_id', plan.userId)
        .count();
    _ensureBelowLimit(
      count: _requiredCount(response.count),
      limit: PlanCatalog.freeCropLimit,
      resource: 'cultivo',
      isPremium: false,
    );
  }

  Future<void> ensureCanCreatePlot() async {
    final plan = await _getPlan();
    if (plan.isPremium) return;

    final response = await _client
        .from('plots')
        .select('id, crops!inner(farms!inner(owner_id))')
        .eq('crops.farms.owner_id', plan.userId)
        .count();
    _ensureBelowLimit(
      count: _requiredCount(response.count),
      limit: PlanCatalog.freePlotLimit,
      resource: 'lote',
      isPremium: false,
    );
  }

  Future<void> ensureCanCreateDiagnosis() async {
    final plan = await _getPlan();
    final limit = plan.isPremium
        ? PlanCatalog.premiumMonthlyDiagnosisLimit
        : PlanCatalog.freeMonthlyDiagnosisLimit;
    final now = DateTime.now().toUtc();
    final monthStart = DateTime.utc(now.year, now.month);
    final nextMonthStart = DateTime.utc(now.year, now.month + 1);
    final count = await _client
        .from('diagnostics')
        .count()
        .eq('user_id', plan.userId)
        .gte('created_at', monthStart.toIso8601String())
        .lt('created_at', nextMonthStart.toIso8601String());
    _ensureBelowLimit(
      count: count,
      limit: limit,
      resource: 'diagnóstico con IA este mes',
      pluralResource: 'diagnósticos con IA este mes',
      isPremium: plan.isPremium,
    );
  }

  Future<void> ensureCanGenerateReport() async {
    final plan = await _getPlan();
    if (!plan.isPremium) {
      throw StateError(
        'La generación de informes PDF es exclusiva del plan Premium. '
        'Actualiza tu plan para usar esta función.',
      );
    }
  }

  Future<void> ensureCanRecordLossEstimation() async {
    final plan = await _getPlan();
    if (!plan.isPremium) {
      throw const ServerFailure(
        'El registro de pérdidas estimadas es exclusivo del plan Premium. '
        'Actualiza tu plan para usar esta función.',
      );
    }
  }

  Future<_UserPlan> _getPlan() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('Tu sesión expiró. Inicia sesión de nuevo.');
    }

    final profile = await _client
        .from('profiles')
        .select('plan_type, premium_until')
        .eq('id', userId)
        .maybeSingle();
    if (profile == null) {
      throw StateError('No se encontró el perfil de tu cuenta.');
    }

    final planType = profile['plan_type']?.toString().toLowerCase();
    final premiumUntil = _parseUtcDate(profile['premium_until']);
    final isPremium =
        planType == 'premium' &&
        premiumUntil != null &&
        premiumUntil.isAfter(DateTime.now().toUtc());
    return _UserPlan(userId: userId, isPremium: isPremium);
  }

  DateTime? _parseUtcDate(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String || value.trim().isEmpty) return null;

    final raw = value.trim();
    final hasTimezone = RegExp(r'(?:[zZ]|[+-]\d{2}:?\d{2})$').hasMatch(raw);
    return DateTime.tryParse(hasTimezone ? raw : '${raw}Z')?.toUtc();
  }

  int _requiredCount(int? count) {
    if (count == null) {
      throw StateError('No se pudo validar el uso de tu plan.');
    }
    return count;
  }

  void _ensureBelowLimit({
    required int count,
    required int limit,
    required String resource,
    String? pluralResource,
    required bool isPremium,
  }) {
    if (count < limit) return;

    final planName = isPremium ? 'Premium' : 'Free';
    final upgradeMessage = isPremium
        ? ''
        : ' Cambia a Premium para ampliar este límite.';
    throw StateError(
      'Alcanzaste el límite de $limit '
      '${limit == 1 ? resource : pluralResource ?? '${resource}s'} '
      'de tu plan $planName.$upgradeMessage',
    );
  }
}

class _UserPlan {
  const _UserPlan({required this.userId, required this.isPremium});

  final String userId;
  final bool isPremium;
}
