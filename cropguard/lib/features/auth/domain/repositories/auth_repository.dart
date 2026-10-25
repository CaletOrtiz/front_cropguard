import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  Future<AuthResponse> signInWithGoogle();
}