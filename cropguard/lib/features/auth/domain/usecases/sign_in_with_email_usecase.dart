import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUsecase {
  const SignInWithEmailUsecase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
