// repositories/profile_repository.dart
import 'package:fpdart/fpdart.dart';

import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<String, UserProfile>> getProfile();
}
