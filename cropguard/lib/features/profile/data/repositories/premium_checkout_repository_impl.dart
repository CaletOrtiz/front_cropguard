import '../../domain/repositories/premium_checkout_repository.dart';
import '../datasources/premium_checkout_remote_data_source.dart';

class PremiumCheckoutRepositoryImpl implements PremiumCheckoutRepository {
  const PremiumCheckoutRepositoryImpl(this._remoteDataSource);

  final PremiumCheckoutRemoteDataSource _remoteDataSource;

  @override
  Future<Uri> createCheckout() => _remoteDataSource.createCheckout();
}
