import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/loss_estimation/domain/entities/loss_estimation.dart';
import 'package:kroppi/features/loss_estimation/presentation/utils/loss_rules.dart';

void main() {
  group('fromJson', () {
    test('preview sin id con warnings', () {
      final estimation = LossEstimation.fromJson({
        'id': null,
        'plot_id': 'p1',
        'expected_yield_kg': 1200,
        'harvested_kg': 900,
        'lost_kg': 300,
        'loss_pct': 25,
        'surplus_kg': 0,
        'price_per_kg': 9000,
        'currency': 'COP',
        'estimated_loss_amount': 2700000,
        'period_from': '2026-05-01',
        'period_to': '2026-11-07',
        'explanation': 'Se esperaban 1.200 kg…',
        'notes': null,
        'warnings': ['No hay cosechas registradas en este periodo'],
        'harvests_in_period': 2,
        'created_at': null,
      });
      expect(estimation.id, isNull);
      expect(estimation.hasLoss, isTrue);
      expect(estimation.periodTo, DateTime(2026, 11, 7));
      expect(estimation.warnings, hasLength(1));
      expect(estimation.createdAt, isNull);
    });

    test('campos opcionales ausentes no fallan', () {
      final estimation = LossEstimation.fromJson({
        'period_from': '2026-05-01',
        'period_to': '2026-11-07',
      });
      expect(estimation.lostKg, 0);
      expect(estimation.warnings, isEmpty);
      expect(estimation.hasLoss, isFalse);
    });

    test('defaults con valores nulos', () {
      final defaults = LossDefaults.fromJson({
        'expected_yield_kg': null,
        'price_per_kg': null,
        'currency': 'COP',
        'period_from': '2026-05-01',
        'period_to': '2026-11-07',
      });
      expect(defaults.expectedYieldKg, isNull);
      expect(defaults.pricePerKg, isNull);
      expect(defaults.periodFrom, DateTime(2026, 5, 1));
    });

    test('lista paginada vacía', () {
      expect(LossPage.fromJson({'items': []}).items, isEmpty);
    });
  });

  group('validadores', () {
    test('hasta < desde', () {
      expect(
        validateLossPeriod(DateTime(2026, 5, 2), DateTime(2026, 5, 1)),
        isNotNull,
      );
      expect(
        validateLossPeriod(DateTime(2026, 5, 1), DateTime(2026, 5, 1)),
        isNull,
      );
    });

    test('rango máximo 2 años', () {
      expect(
        validateLossPeriod(DateTime(2024, 1, 1), DateTime(2026, 1, 2)),
        isNotNull,
      );
      expect(
        validateLossPeriod(DateTime(2024, 1, 1), DateTime(2026, 1, 1)),
        isNull,
      );
    });

    test('aviso de periodo futuro', () {
      final now = DateTime(2026, 11, 7);
      expect(futurePeriodWarning(DateTime(2026, 11, 8), now: now), isNotNull);
      expect(futurePeriodWarning(DateTime(2026, 11, 7), now: now), isNull);
    });

    test('kilos esperados > 0 y precio >= 0', () {
      expect(validateExpectedKg('0'), isNotNull);
      expect(validateExpectedKg('1.200'), isNull);
      expect(validateRequiredPrice(''), isNotNull);
      expect(validateRequiredPrice('0'), isNull);
    });
  });

  test('severidad del porcentaje', () {
    expect(lossSeverity(0), LossSeverity.none);
    expect(lossSeverity(14.99), LossSeverity.low);
    expect(lossSeverity(15), LossSeverity.high);
  });
}
