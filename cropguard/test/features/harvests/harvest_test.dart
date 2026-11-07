import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/harvests/domain/entities/harvest.dart';
import 'package:kroppi/features/harvests/presentation/utils/harvest_validators.dart';

void main() {
  group('fromJson', () {
    test('cosecha con precio', () {
      final harvest = Harvest.fromJson({
        'id': 'h1',
        'plot_id': 'p1',
        'harvested_at': '2026-11-05',
        'quantity_kg': 850,
        'price_per_kg': 9000,
        'currency': 'COP',
        'value': 7650000,
        'notes': null,
      });
      expect(harvest.harvestedAt, DateTime(2026, 11, 5));
      expect(harvest.quantityKg, 850.0);
      expect(harvest.value, 7650000.0);
    });

    test('cosecha sin precio ni moneda', () {
      final harvest = Harvest.fromJson({
        'id': 'h1',
        'harvested_at': '2026-11-05',
        'quantity_kg': 10.5,
      });
      expect(harvest.pricePerKg, isNull);
      expect(harvest.value, isNull);
      expect(harvest.currency, 'COP');
    });

    test('página con totales por moneda y listas vacías', () {
      final page = HarvestPage.fromJson({
        'items': [],
        'totals': {
          'quantity_kg': 1700,
          'by_currency': [
            {'currency': 'COP', 'revenue': 15300000, 'harvests_with_price': 2},
            {'currency': 'USD', 'revenue': 10.5, 'harvests_with_price': 1},
          ],
          'harvests_without_price': 0,
        },
        'next_offset': null,
      });
      expect(page.items, isEmpty);
      expect(page.totals.byCurrency.map((row) => row.currency), ['COP', 'USD']);
      expect(page.nextOffset, isNull);
    });

    test('página sin totales no falla', () {
      final page = HarvestPage.fromJson({'items': []});
      expect(page.totals, const HarvestTotals());
    });

    test('resultado de guardar con estimaciones afectadas', () {
      final result = HarvestSaveResult.fromJson({
        'id': 'h1',
        'harvested_at': '2026-11-05',
        'quantity_kg': 5,
        'affects_estimations': ['e1'],
      });
      expect(result.affectsEstimations, ['e1']);
    });
  });

  test('toJson limpia observaciones vacías', () {
    final json = HarvestInput(
      harvestedAt: DateTime(2026, 11, 5),
      quantityKg: 12.5,
      notes: '   ',
    ).toJson();
    expect(json['harvested_at'], '2026-11-05');
    expect(json['notes'], isNull);
    expect(json['price_per_kg'], isNull);
  });

  group('validadores', () {
    final now = DateTime(2026, 11, 7);

    test('fecha futura no permitida', () {
      expect(validateHarvestDate(DateTime(2026, 11, 8), now: now), isNotNull);
      expect(validateHarvestDate(DateTime(2026, 11, 7), now: now), isNull);
    });

    test('cantidad debe ser > 0', () {
      expect(validateHarvestQuantity(''), isNotNull);
      expect(validateHarvestQuantity('0'), isNotNull);
      expect(validateHarvestQuantity('0,5'), isNull);
    });

    test('precio opcional pero válido', () {
      expect(validateOptionalPrice(''), isNull);
      expect(validateOptionalPrice('9.000'), isNull);
    });
  });
}
