import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/farms/domain/entities/farm.dart';
import 'package:kroppi/features/home/domain/entities/home_dashboard.dart';

void main() {
  group('HomeDashboard', () {
    test('calculates summary values from real farm data', () {
      const dashboard = HomeDashboard(
        farms: [
          Farm(
            id: 'farm-1',
            name: 'La Esperanza',
            areaHa: 12.5,
            cropCount: 2,
            plotCount: 4,
            alertPlots: 1,
          ),
          Farm(
            id: 'farm-2',
            name: 'El Porvenir',
            areaHa: 8,
            cropCount: 1,
            plotCount: 3,
            dangerPlots: 1,
          ),
        ],
        pendingSamplings: [],
      );

      expect(dashboard.totalFarms, 2);
      expect(dashboard.totalPlots, 7);
      expect(dashboard.alertPlots, 1);
      expect(dashboard.dangerPlots, 1);
      expect(dashboard.isEmpty, isFalse);
    });

    test('marks farms as empty when the query returns none', () {
      const dashboard = HomeDashboard(farms: [], pendingSamplings: []);

      expect(dashboard.isEmpty, isTrue);
      expect(dashboard.totalFarms, 0);
    });
  });
}
