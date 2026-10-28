import '../entities/app_user.dart';
import '../entities/sign_up_params.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUsecase {
  const SignUpWithEmailUsecase(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call(SignUpParams params) {
    return _repository.signUpWithEmail(params);
  }
}
