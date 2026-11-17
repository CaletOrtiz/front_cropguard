import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kroppi/core/network/supabase/android_auth_storage.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart' as app;

class MemoryVault extends Mock implements FlutterSecureStorage {
  final values = <String, String>{};
  bool failWrites = false;
  Completer<void>? writeGate;
  Completer<void>? writeStarted;

  MemoryVault() {
    when(
      () => read(key: any(named: 'key')),
    ).thenAnswer((call) async => values[call.namedArguments[#key]]);
    when(
      () => write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((call) async {
      if (failWrites) {
        throw PlatformException(code: 'test-failure');
      }
      if (writeStarted != null && !writeStarted!.isCompleted) {
        writeStarted!.complete();
      }
      await writeGate?.future;
      values[call.namedArguments[#key] as String] =
          call.namedArguments[#value] as String;
    });
    when(() => delete(key: any(named: 'key'))).thenAnswer((call) async {
      values.remove(call.namedArguments[#key]);
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const key = 'sb-test-project-auth-token';
  const verifier = 'supabase.auth.token-code-verifier';
  const fixture =
      '{"access_token":"synthetic-access","refresh_token":"synthetic-refresh"}';

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'migrates existing session and pending PKCE, verifies copy, removes plaintext',
    () async {
      SharedPreferences.setMockInitialValues({
        key: fixture,
        verifier: 'synthetic-verifier',
      });
      final vault = MemoryVault();
      final storage = AndroidAuthStorage(sessionKey: key, secureStorage: vault);
      await storage.initialize();
      final prefs = await SharedPreferences.getInstance();
      expect(await storage.accessToken() == fixture, isTrue);
      expect(
        await storage.pkceStorage.getItem(key: verifier) ==
            'synthetic-verifier',
        isTrue,
      );
      expect(prefs.containsKey(key), isFalse);
      expect(prefs.containsKey(verifier), isFalse);
      final reopened = AndroidAuthStorage(
        sessionKey: key,
        secureStorage: vault,
      );
      expect(await reopened.accessToken() == fixture, isTrue);
    },
  );

  test('secure state wins over a stale legacy session', () async {
    SharedPreferences.setMockInitialValues({key: 'stale-synthetic-session'});
    final vault = MemoryVault()..values[key] = fixture;
    final storage = AndroidAuthStorage(sessionKey: key, secureStorage: vault);
    expect(await storage.accessToken() == fixture, isTrue);
    expect((await SharedPreferences.getInstance()).containsKey(key), isFalse);
  });

  test(
    'failed migration does not restore plaintext or discard the only copy',
    () async {
      SharedPreferences.setMockInitialValues({key: fixture});
      final vault = MemoryVault()..failWrites = true;
      final storage = AndroidAuthStorage(sessionKey: key, secureStorage: vault);
      await expectLater(storage.initialize(), throwsStateError);
      await expectLater(storage.accessToken(), throwsStateError);
      expect(
        (await SharedPreferences.getInstance()).getString(key) == fixture,
        isTrue,
      );
      expect(vault.values.containsKey(key), isFalse);
    },
  );

  test(
    'sign-out deletion waits for an in-flight write and prevents resurrection',
    () async {
      final vault = MemoryVault();
      final storage = AndroidAuthStorage(sessionKey: key, secureStorage: vault);
      await storage.initialize();
      vault.writeGate = Completer<void>();
      vault.writeStarted = Completer<void>();
      final writing = storage.persistSession(fixture);
      await vault.writeStarted!.future;
      final deleting = storage.removePersistedSession();
      vault.writeGate!.complete();
      await Future.wait([writing, deleting]);
      expect(await storage.hasAccessToken(), isFalse);
      final reopened = AndroidAuthStorage(
        sessionKey: key,
        secureStorage: vault,
      );
      expect(await reopened.hasAccessToken(), isFalse);
    },
  );

  test(
    'PKCE uses secure API and sign-out clears session and verifier',
    () async {
      final vault = MemoryVault();
      final storage = AndroidAuthStorage(sessionKey: key, secureStorage: vault);
      await storage.persistSession(fixture);
      await storage.pkceStorage.setItem(
        key: verifier,
        value: 'synthetic-verifier',
      );
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
      await storage.removePersistedSession();
      expect(await storage.accessToken(), isNull);
      expect(await storage.pkceStorage.getItem(key: verifier), isNull);
    },
  );

  test(
    'Android selects secure storage; other native platforms retain SDK defaults',
    () {
      final previous = debugDefaultTargetPlatformOverride;
      try {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        expect(
          app.SupabaseClient.createSessionStorage(),
          isA<AndroidAuthStorage>(),
        );
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        expect(app.SupabaseClient.createSessionStorage(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = previous;
      }
    },
  );
}
