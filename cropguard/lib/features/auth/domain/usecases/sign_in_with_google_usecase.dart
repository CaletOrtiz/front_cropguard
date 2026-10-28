import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase {
  const SignInWithGoogleUsecase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() {
    return _repository.signInWithGoogle();
  }
}
