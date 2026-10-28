import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kroppi/features/auth/data/models/app_user_model.dart';
import '../../domain/entities/update_profile_params.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _bucket = 'avatars';
  static const _publicPrefix = '/storage/v1/object/public/$_bucket/';

  /// 1) Sube la foto (si hay) a `avatars/<uid>/...`.
  /// 2) Llama a la función `update_my_profile`, que valida el rol y guarda
  ///    celular, municipio, rol y foto en `profiles`.
  /// 3) Borra la foto anterior.
  Future<AppUserModel> updateProfile(UpdateProfileParams params) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw const AuthException('Tu sesión expiró. Inicia sesión de nuevo.');
    }

    String? uploadedPath;
    String? avatarUrl;

    final avatar = params.avatar;
    if (avatar != null) {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      uploadedPath =
          '${authUser.id}/avatar_$stamp.${_extension(avatar.contentType)}';
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            uploadedPath,
            avatar.bytes,
            fileOptions: FileOptions(contentType: avatar.contentType),
          );
      avatarUrl = _client.storage.from(_bucket).getPublicUrl(uploadedPath);
    }

    Object? result;
    try {
      result = await _client.rpc(
        'update_my_profile',
        params: {
          'p_phone_number': params.phoneNumber,
          'p_municipality': params.municipality,
          'p_role': params.role,
          'p_avatar_url': avatarUrl,
        },
      );
    } catch (_) {
      // No dejar una foto huérfana si el perfil no se pudo guardar.
      if (uploadedPath != null) await _removeQuietly(uploadedPath);
      rethrow;
    }

    if (result is! Map) {
      throw const PostgrestException(
        message: 'Respuesta inesperada al guardar el perfil.',
      );
    }

    if (avatarUrl != null) {
      final oldPath = _pathFromPublicUrl(
        params.previousAvatarUrl,
        authUser.id,
      );
      if (oldPath != null && oldPath != uploadedPath) {
        await _removeQuietly(oldPath);
      }
    }

    return AppUserModel.fromProfile(
      Map<String, dynamic>.from(result),
      email: authUser.email ?? '',
    );
  }

  String _extension(String contentType) => switch (contentType) {
    'image/png' => 'png',
    'image/webp' => 'webp',
    _ => 'jpg',
  };

  /// Ruta dentro del bucket si la URL es una foto propia del usuario; null
  /// para fotos de otro origen (por ejemplo, la de Google).
  String? _pathFromPublicUrl(String? url, String userId) {
    if (url == null) return null;
    final index = url.indexOf(_publicPrefix);
    if (index < 0) return null;
    final path = Uri.decodeComponent(
      url.substring(index + _publicPrefix.length).split('?').first,
    );
    return path.startsWith('$userId/') ? path : null;
  }

  Future<void> _removeQuietly(String path) async {
    try {
      await _client.storage.from(_bucket).remove([path]);
    } catch (_) {
      // Limpieza opcional: si falla, no se interrumpe el guardado.
    }
  }
}
