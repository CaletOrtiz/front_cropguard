import 'package:kroppi/features/auth/domain/entities/app_user.dart';

import '../entities/update_profile_params.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUsecase {
  const UpdateProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<AppUser> call(UpdateProfileParams params) {
    return _repository.updateProfile(params);
  }
}
