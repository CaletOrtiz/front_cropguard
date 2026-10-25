import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase/supabase_auth_service.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._authService);

  final SupabaseAuthService _authService;

  Future<AuthResponse> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }
}