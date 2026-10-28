import 'package:kroppi/core/errors/guard.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/sign_up_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  /// Google se deja sin traducir de errores (como antes); solo se agrega la
  /// validación del perfil.
  @override
  Future<AppUser> signInWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return guardCall<AppUser>(
      () => _remoteDataSource.signInWithEmail(
        email: email.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<AppUser?> signUpWithEmail(SignUpParams params) {
    return guardCall<AppUser?>(
      () => _remoteDataSource.signUpWithEmail(
        SignUpParams(
          fullName: params.fullName.trim(),
          email: params.email.trim(),
          password: params.password,
          phoneNumber: params.phoneNumber,
          municipality: params.municipality,
          department: params.department,
          role: params.role,
        ),
      ),
    );
  }

  @override
  Future<void> signOut() {
    return guardCall(_remoteDataSource.signOut);
  }

  @override
  Future<AppUser?> getCurrentUser() {
    return guardCall<AppUser?>(_remoteDataSource.getCurrentUser);
  }
}
