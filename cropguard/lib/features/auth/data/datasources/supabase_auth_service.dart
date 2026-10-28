import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/sign_up_params.dart';

class SupabaseAuthService {
  SupabaseAuthService(this._client) : _googleSignIn = GoogleSignIn.instance;

  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleSignInInitialization;

  static const _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '302834720640-e91fk4kj1rnc3su728tccig6ogkisq7m.apps.googleusercontent.com',
  );
  static const _iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  // ---------------- Correo y contraseña ----------------

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Los datos del formulario viajan como metadata; el trigger
  /// `handle_new_user` los copia a `profiles` (ver supabase/01_registro_perfiles.sql).
  Future<AuthResponse> signUpWithEmail(SignUpParams params) {
    return _client.auth.signUp(
      email: params.email,
      password: params.password,
      data: {
        'full_name': params.fullName,
        if (params.phoneNumber != null) 'phone_number': params.phoneNumber,
        if (params.municipality != null) 'municipality': params.municipality,
        if (params.department != null) 'department': params.department,
        'role': params.role,
      },
    );
  }

  // ---------------- Google (sin cambios) ----------------

  Future<AuthResponse> signInWithGoogle() async {
    if (_webClientId.isEmpty) {
      throw const AuthException(
        'Configura GOOGLE_WEB_CLIENT_ID para habilitar el inicio con Google.',
      );
    }

    await (_googleSignInInitialization ??= _googleSignIn.initialize(
      serverClientId: _webClientId,
      clientId: _iosClientId.isEmpty ? null : _iosClientId,
    ));

    final googleUser = await _googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('No se obtuvo el ID token de Google');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  // ---------------- Perfil ----------------

  /// Fila de `public.profiles` del usuario, o null si no existe.
  Future<Map<String, dynamic>?> fetchProfile(String userId) {
    return _client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  // ---------------- Sesión ----------------

  Future<void> signOut() async {
    // Con google_sign_in 7.x, signOut() exige haber llamado a initialize().
    // Quien entró con correo nunca lo hizo, así que solo cerramos Google
    // cuando se usó en esta ejecución.
    if (_googleSignInInitialization != null) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
