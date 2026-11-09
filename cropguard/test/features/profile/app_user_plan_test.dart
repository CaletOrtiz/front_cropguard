import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/auth/data/models/app_user_model.dart';
import 'package:kroppi/features/profile/domain/entities/plan_catalog.dart';

void main() {
  group('AppUser Premium plan status', () {
    const email = 'agricultor@kroppi.co';
    final now = DateTime.utc(2026, 11, 8, 12);

    test('Premium is active only before its UTC expiration', () {
      final user = AppUserModel.fromProfile({
        'id': 'user-1',
        'plan_type': 'premium',
        'premium_until': '2026-11-08T13:00:00Z',
      }, email: email);

      expect(user.isPremiumActiveAt(now), isTrue);
      expect(user.isPremiumExpiredAt(now), isFalse);
    });

    test('expired Premium is reported as expired, not active', () {
      final user = AppUserModel.fromProfile({
        'id': 'user-1',
        'plan_type': 'premium',
        'premium_until': '2026-11-08T08:00:00-03:00',
      }, email: email);

      expect(user.isPremiumActiveAt(now), isFalse);
      expect(user.isPremiumExpiredAt(now), isTrue);
    });

    test('missing or invalid expiration leaves the user on Free', () {
      final user = AppUserModel.fromProfile({
        'id': 'user-1',
        'plan_type': 'premium',
        'premium_until': null,
      }, email: email);
      final invalidDateUser = AppUserModel.fromProfile({
        'id': 'user-2',
        'plan_type': 'premium',
        'premium_until': 'invalid',
      }, email: email);

      expect(user.isPremiumActiveAt(now), isFalse);
      expect(user.isPremiumExpiredAt(now), isFalse);
      expect(invalidDateUser.isPremiumActiveAt(now), isFalse);
    });

    test('a timezone-free database timestamp is interpreted as UTC', () {
      final user = AppUserModel.fromProfile({
        'id': 'user-1',
        'plan_type': 'premium',
        'premium_until': '2026-11-08T13:00:00',
      }, email: email);

      expect(user.isPremiumActiveAt(now), isTrue);
    });
  });

  test('plan catalog centralizes Free and Premium limits', () {
    expect(PlanCatalog.freeFarmLimit, 1);
    expect(PlanCatalog.freeCropLimit, 2);
    expect(PlanCatalog.freePlotLimit, 5);
    expect(PlanCatalog.freeMonthlyDiagnosisLimit, 3);
    expect(PlanCatalog.premiumMonthlyDiagnosisLimit, 30);
    expect(PlanCatalog.premiumPriceInCop, 19900);
    expect(PlanCatalog.premiumDurationDays, 30);
  });
}
