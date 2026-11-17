import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kroppi/core/network/supabase/android_auth_storage.dart';
import 'package:kroppi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kroppi/features/auth/data/datasources/supabase_auth_service.dart';
import 'android_auth_storage_test.dart' show MemoryVault;

const _key = 'sb-session-test-auth-token';
const _id = '00000000-0000-4000-8000-000000000001';
const _user = {
  'id': _id,
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': 'test@example.invalid',
  'created_at': '2026-01-01T00:00:00Z',
};

String _jwt(int sequence) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode({'sub': _id, 'role': 'authenticated', 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600})}.${encode('synthetic-$sequence')}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'real SDK + app data source: sign-in, refresh, reopen, sign-out, reopen',
    () async {
      SharedPreferences.setMockInitialValues({});
      final vault = MemoryVault();
      var sequence = 0;
      var initialized = false;
      late AndroidAuthStorage activeStorage;
      Future<AuthRemoteDataSource> open() async {
        final storage = AndroidAuthStorage(
          sessionKey: _key,
          secureStorage: vault,
        );
        activeStorage = storage;
        await Supabase.initialize(
          url: 'https://session-test.supabase.co',
          publishableKey: 'synthetic-public-client-key',
          debug: false,
          httpClient: MockClient((request) async {
            if (request.url.path.endsWith('/token')) {
              sequence++;
              return http.Response(
                jsonEncode({
                  'access_token': _jwt(sequence),
                  'refresh_token': 'synthetic-refresh-$sequence',
                  'token_type': 'bearer',
                  'expires_in': 3600,
                  'user': _user,
                }),
                200,
                headers: {'content-type': 'application/json'},
                request: request,
              );
            }
            if (request.url.path.endsWith('/logout')) {
              return http.Response('', 204);
            }
            if (request.url.path.endsWith('/user')) {
              return http.Response(jsonEncode(_user), 200);
            }
            if (request.url.path.endsWith('/profiles')) {
              return http.Response(
                jsonEncode({
                  'id': _id,
                  'full_name': 'Synthetic User',
                  'role': 'farmer',
                }),
                200,
                headers: {'content-type': 'application/json'},
                request: request,
              );
            }
            throw StateError('Unexpected fixture endpoint.');
          }),
          authOptions: FlutterAuthClientOptions(
            localStorage: storage,
            pkceAsyncStorage: storage.pkceStorage,
            autoRefreshToken: false,
            detectSessionInUri: false,
          ),
        );
        initialized = true;
        return AuthRemoteDataSource(
          SupabaseAuthService(
            Supabase.instance.client,
            sessionStorage: storage,
          ),
        );
      }

      addTearDown(() async {
        if (initialized) await Supabase.instance.dispose();
      });
      var remote = await open();
      final user = await remote.signInWithEmail(
        email: 'test@example.invalid',
        password: 'synthetic-password',
      );
      expect(user.id, _id);
      var storage = activeStorage;
      expect(await storage.hasAccessToken(), isTrue);
      expect(
        (await SharedPreferences.getInstance()).containsKey(_key),
        isFalse,
      );
      await Supabase.instance.client.auth.refreshSession();
      final persisted =
          jsonDecode((await storage.accessToken())!) as Map<String, dynamic>;
      expect(
        persisted['refresh_token'] == 'synthetic-refresh-$sequence',
        isTrue,
      );
      await Supabase.instance.dispose();
      initialized = false;
      remote = await open();
      expect((await remote.getCurrentUser())?.id, _id);
      await remote.signOut();
      storage = AndroidAuthStorage(sessionKey: _key, secureStorage: vault);
      expect(await storage.hasAccessToken(), isFalse);
      await Supabase.instance.dispose();
      initialized = false;
      remote = await open();
      expect(await remote.getCurrentUser(), isNull);
      expect(await storage.hasAccessToken(), isFalse);
      // Same SDK path used after the native Google SDK obtains its ID token.
      vault.writeStarted = Completer<void>();
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: 'synthetic-id-token',
      );
      await vault.writeStarted!.future.timeout(const Duration(seconds: 5));
      expect(await activeStorage.hasAccessToken(), isTrue);
      await remote.signOut();
      expect(await activeStorage.hasAccessToken(), isFalse);
    },
  );
}
