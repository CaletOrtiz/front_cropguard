import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> signInWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }
}
