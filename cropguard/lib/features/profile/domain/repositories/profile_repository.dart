import 'package:kroppi/features/auth/domain/entities/app_user.dart';

import '../entities/update_profile_params.dart';

abstract interface class ProfileRepository {
  /// Guarda los cambios (y la foto, si hay) y devuelve el perfil actualizado.
  Future<AppUser> updateProfile(UpdateProfileParams params);
}
