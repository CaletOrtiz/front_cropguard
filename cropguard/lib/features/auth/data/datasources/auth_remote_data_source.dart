import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kroppi/core/errors/failures.dart';
import 'package:kroppi/features/auth/data/datasources/supabase_auth_service.dart';
import 'package:kroppi/features/auth/data/models/app_user_model.dart';
import 'package:kroppi/features/auth/domain/entities/sign_up_params.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._authService);

  final SupabaseAuthService _authService;

  Future<AppUserModel> signInWithGoogle() async {
    final response = await _authService.signInWithGoogle();
    final user = response.user;
    if (user == null) {
      throw const AuthException('No se pudo iniciar sesión con Google');
    }
    return _withProfile(user);
  }

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Invalid login credentials');
    }
    return _withProfile(user);
  }

  Future<AppUserModel?> signUpWithEmail(SignUpParams params) async {
    final response = await _authService.signUpWithEmail(params);
    final user = response.user;
    if (user == null) {
      throw const AuthException('No se pudo crear la cuenta');
    }
    // Con la confirmación de correo activa, Supabase no devuelve error si el
    // correo ya existe: devuelve un usuario sin identidades.
    if (user.identities != null && user.identities!.isEmpty) {
      throw const AuthException('User already registered');
    }
    // Sin sesión = Supabase está esperando que se confirme el correo.
    if (response.session == null) return null;
    return _withProfile(user);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  /// Sesión restaurada por el SDK + su perfil. Si la sesión existe pero el
  /// perfil no, se cierra y se trata como "sin sesión".
  Future<AppUserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    final row = await _authService.fetchProfile(user.id);
    if (row == null) {
      await _authService.signOut();
      return null;
    }
    return AppUserModel.fromProfile(row, email: user.email ?? '');
  }

  /// Valida que el usuario tenga fila en `profiles`. Sin perfil no se
  /// permite entrar: se cierra la sesión y se informa.
  Future<AppUserModel> _withProfile(User user) async {
    final row = await _authService.fetchProfile(user.id);
    if (row == null) {
      await _authService.signOut();
      throw const NotFoundFailure(
        'Tu cuenta no tiene un perfil asociado. Contacta a soporte.',
      );
    }
    return AppUserModel.fromProfile(row, email: user.email ?? '');
  }
}
