import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart';
import 'android_auth_storage.dart';

class SupabaseClient {
  static const String baseUrl = 'https://isvpbjbgegbgyxagbwko.supabase.co';
  static const String apiKey = 'sb_publishable_z-vrMOmZd5eXjrvgDVRcZA_0A92UmWq';

  static Future<void> init() async {
    _sessionStorage = createSessionStorage();
    await supabase.Supabase.initialize(
      url: baseUrl,
      publishableKey: apiKey,
      authOptions: supabase.FlutterAuthClientOptions(
        localStorage: _sessionStorage,
        pkceAsyncStorage: _sessionStorage?.pkceStorage,
      ),
    );
  }

  static AndroidAuthStorage? _sessionStorage;
  static supabase.LocalStorage? get sessionStorage => _sessionStorage;

  static AndroidAuthStorage? createSessionStorage() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? AndroidAuthStorage(
          sessionKey:
              'sb-${Uri.parse(baseUrl).host.split('.').first}-auth-token',
        )
      : null;

  static supabase.SupabaseClient get client =>
      supabase.Supabase.instance.client;
}
