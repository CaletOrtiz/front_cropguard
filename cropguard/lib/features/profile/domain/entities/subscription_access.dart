enum PlanResource {
  farms('Fincas'),
  crops('Cultivos'),
  plots('Lotes'),
  diagnoses('Diagnósticos con IA');

  const PlanResource(this.label);
  final String label;
}

class PlanQuota {
  const PlanQuota(this.limit, this.used, this.left);

  final int? limit;
  final int used;
  final int? left;

  bool get exhausted => left == 0;

  String get summary => limit == null
      ? '$used registrados · Sin límite'
      : '$used de $limit usados · $left disponibles';
}

class SubscriptionAccess {
  SubscriptionAccess.fromJson(Map<String, dynamic> json)
    : plan = json['plan_type'] as String,
      premiumFeatures = json['premium_features_available'] as bool,
      premiumUntil = json['premium_until'] == null
          ? null
          : DateTime.parse(json['premium_until'] as String),
      startsAt = DateTime.parse(
        json['diagnosis_period']['starts_at'] as String,
      ),
      renewsAt = DateTime.parse(
        json['diagnosis_period']['renews_at'] as String,
      ),
      quotas = Map.unmodifiable({
        for (final resource in PlanResource.values)
          resource: _quota(json, resource.name),
      }) {
    if ((plan != 'free' && plan != 'premium') ||
        quotas[PlanResource.diagnoses]!.limit == null) {
      throw const FormatException('Estado de suscripción inválido.');
    }
  }

  final String plan;
  final bool premiumFeatures;
  final DateTime? premiumUntil;
  final DateTime startsAt;
  final DateTime renewsAt;
  final Map<PlanResource, PlanQuota> quotas;

  bool allowsDiagnosisHistoryAt(DateTime date) =>
      premiumFeatures || !date.isBefore(startsAt);

  bool get isPremium => plan == 'premium';
  PlanQuota quota(PlanResource resource) => quotas[resource]!;

  static PlanQuota _quota(Map<String, dynamic> json, String key) {
    final limits = json['limits'] as Map;
    final remaining = json['remaining'] as Map;
    if (!limits.containsKey(key) || !remaining.containsKey(key)) {
      throw const FormatException('Cuota de suscripción incompleta.');
    }
    final limit = limits[key] as int?;
    final used = json['usage'][key] as int;
    final left = remaining[key] as int?;
    if (used < 0 ||
        (limit == null
            ? left != null
            : left != (limit - used).clamp(0, limit))) {
      throw const FormatException('Cuota de suscripción inválida.');
    }
    return PlanQuota(limit, used, left);
  }
}
