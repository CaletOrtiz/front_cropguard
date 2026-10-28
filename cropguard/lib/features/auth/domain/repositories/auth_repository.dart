import '../entities/app_user.dart';
import '../entities/sign_up_params.dart';

abstract interface class AuthRepository {
  /// Inicia sesión con Google y valida que exista el perfil del usuario.
  Future<AppUser> signInWithGoogle();

  /// Inicia sesión con correo y valida que exista el perfil del usuario.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Devuelve null cuando Supabase exige confirmar el correo antes de
  /// iniciar sesión (no hay sesión activa todavía).
  Future<AppUser?> signUpWithEmail(SignUpParams params);

  Future<void> signOut();

  /// Restaura la sesión guardada junto con su perfil; null si no hay.
  Future<AppUser?> getCurrentUser();
}
