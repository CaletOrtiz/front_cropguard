import 'package:kroppi/features/auth/data/datasources/supabase_auth_service.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._authService);

  final SupabaseAuthService _authService;

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> signOut() {
    return _authService.signOut();
  }
}