import 'package:kroppi/core/errors/guard.dart';
import 'package:kroppi/features/auth/domain/entities/app_user.dart';

import '../../domain/entities/update_profile_params.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<AppUser> updateProfile(UpdateProfileParams params) {
    return guardCall<AppUser>(() => _remoteDataSource.updateProfile(params));
  }
}
