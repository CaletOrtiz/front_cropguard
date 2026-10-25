import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
