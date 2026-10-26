// usecases/get_profile.dart
import 'package:fpdart/fpdart.dart';

import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;
  GetProfile(this.repository);

  Future<Either<String, UserProfile>> call() => repository.getProfile();
}
