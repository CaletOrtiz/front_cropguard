import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase {
  const SignInWithGoogleUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.signInWithGoogle();
  }
}