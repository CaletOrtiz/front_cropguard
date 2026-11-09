import '../repositories/premium_checkout_repository.dart';

class CreatePremiumCheckoutUsecase {
  const CreatePremiumCheckoutUsecase(this._repository);

  final PremiumCheckoutRepository _repository;

  Future<Uri> call() => _repository.createCheckout();
}
