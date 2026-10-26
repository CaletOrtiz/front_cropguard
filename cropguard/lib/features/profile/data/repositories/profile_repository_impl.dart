// repositories/profile_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl(this.remote);

  @override
  Future<Either<String, UserProfile>> getProfile() async {
    try {
      return Right(await remote.getProfile());
    } on AuthException catch (e) {
      return Left(e.message);
    } on PostgrestException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Error inesperado: $e');
    }
  }
}
