import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Android-only storage for Supabase sessions and PKCE verifiers.
/// The SDK still owns refresh, expiry and auth-state notifications.
class AndroidAuthStorage extends LocalStorage {
  factory AndroidAuthStorage({
    required String sessionKey,
    FlutterSecureStorage? secureStorage,
    LocalStorage? legacyStorage,
    GotrueAsyncStorage? legacyPkceStorage,
  }) {
    final legacy = _LegacyAuthStorage(sessionKey);
    return AndroidAuthStorage._(
      sessionKey,
      secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              storageNamespace: 'kroppi.supabase.auth',
              resetOnError: false,
              keyCipherAlgorithm:
                  KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
              storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
            ),
          ),
      legacyStorage ?? legacy,
      legacyPkceStorage ?? legacy,
    );
  }

  AndroidAuthStorage._(
    this.sessionKey,
    this._secure,
    this._legacy,
    this._legacyPkce,
  );

  final String sessionKey;
  final FlutterSecureStorage _secure;
  final LocalStorage _legacy;
  final GotrueAsyncStorage _legacyPkce;
  Future<void>? _initialization;
  Future<void> _tail = Future.value();
  late final GotrueAsyncStorage pkceStorage = _SecurePkceStorage(this);

  // Default verifier key in the installed gotrue 2.27.2 SDK.
  static const _legacyVerifierKey = 'supabase.auth.token-code-verifier';
  String _pkceKey(String key) => '$sessionKey:pkce:$key';

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _tail.then((_) async {
      try {
        return await operation();
      } catch (_) {
        // Never copy native error details or session contents into UI/logs.
        throw StateError(
          'No se pudo acceder al almacenamiento seguro de sesión.',
        );
      }
    });
    // A failed operation must not prevent a later explicit deletion.
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<T> _ready<T>(Future<T> Function() operation) async {
    await initialize();
    return _enqueue(operation);
  }

  Future<void> _migrate(
    String key,
    Future<String?> Function() readLegacy,
    Future<void> Function() removeLegacy,
  ) async {
    final current = await _secure.read(key: key);
    final previous = await readLegacy();
    if (current == null && previous != null) {
      await _secure.write(key: key, value: previous);
      if (await _secure.read(key: key) != previous) {
        throw StateError('No se pudo verificar la migración de sesión.');
      }
    }
    // Delete only after the encrypted copy was successfully verified.
    await removeLegacy();
  }

  @override
  Future<void> initialize() => _initialization ??= _enqueue(() async {
    await _legacy.initialize();
    await _migrate(
      sessionKey,
      _legacy.accessToken,
      _legacy.removePersistedSession,
    );
    await _migrate(
      _pkceKey(_legacyVerifierKey),
      () => _legacyPkce.getItem(key: _legacyVerifierKey),
      () => _legacyPkce.removeItem(key: _legacyVerifierKey),
    );
  });

  @override
  Future<String?> accessToken() => _ready(() => _secure.read(key: sessionKey));

  @override
  Future<bool> hasAccessToken() async =>
      (await accessToken())?.isNotEmpty ?? false;

  @override
  Future<void> persistSession(String persistSessionString) => _ready(() async {
    await _secure.write(key: sessionKey, value: persistSessionString);
    await _legacy.removePersistedSession();
  });

  @override
  Future<void> removePersistedSession() => _ready(() async {
    try {
      await _secure.delete(key: sessionKey);
      await _secure.delete(key: _pkceKey(_legacyVerifierKey));
    } finally {
      await _legacy.removePersistedSession();
      await _legacyPkce.removeItem(key: _legacyVerifierKey);
    }
  });
}

class _SecurePkceStorage extends GotrueAsyncStorage {
  _SecurePkceStorage(this.owner);
  final AndroidAuthStorage owner;

  @override
  Future<String?> getItem({required String key}) => owner._ready(() async {
    await owner._migrate(
      owner._pkceKey(key),
      () => owner._legacyPkce.getItem(key: key),
      () => owner._legacyPkce.removeItem(key: key),
    );
    return owner._secure.read(key: owner._pkceKey(key));
  });

  @override
  Future<void> setItem({required String key, required String value}) =>
      owner._ready(() async {
        await owner._secure.write(key: owner._pkceKey(key), value: value);
        await owner._legacyPkce.removeItem(key: key);
      });

  @override
  Future<void> removeItem({required String key}) => owner._ready(() async {
    await owner._secure.delete(key: owner._pkceKey(key));
    await owner._legacyPkce.removeItem(key: key);
  });
}

/// Read-only migration source. Confirm deletion instead of ignoring the native
/// commit result as the SDK's legacy adapter does.
class _LegacyAuthStorage extends LocalStorage implements GotrueAsyncStorage {
  _LegacyAuthStorage(this.sessionKey);
  final String sessionKey;
  SharedPreferences? _preferences;

  @override
  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getItem({required String key}) async {
    await initialize();
    return _preferences!.getString(key);
  }

  @override
  Future<void> removeItem({required String key}) async {
    await initialize();
    if (!await _preferences!.remove(key)) {
      throw StateError('No se pudo borrar la sesión anterior.');
    }
    await _preferences!.reload();
    if (_preferences!.containsKey(key)) {
      throw StateError('La sesión anterior sigue almacenada.');
    }
  }

  @override
  Future<String?> accessToken() => getItem(key: sessionKey);

  @override
  Future<bool> hasAccessToken() async => await accessToken() != null;

  @override
  Future<void> removePersistedSession() => removeItem(key: sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) async {
    throw StateError('El almacenamiento anterior solo permite migración.');
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    throw StateError('El almacenamiento anterior solo permite migración.');
  }
}
