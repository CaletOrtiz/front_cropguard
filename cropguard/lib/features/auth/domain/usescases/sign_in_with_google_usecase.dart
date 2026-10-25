import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase {
  const SignInWithGoogleUsecase(this._repository);

  final AuthRepository _repository;

  Future<AuthResponse> call() {
    return _repository.signInWithGoogle();
  }
}