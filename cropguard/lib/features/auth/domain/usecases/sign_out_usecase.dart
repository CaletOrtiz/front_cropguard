import '../repositories/auth_repository.dart';

class SignOutUsecase {
  const SignOutUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.signOut();
  }
}
