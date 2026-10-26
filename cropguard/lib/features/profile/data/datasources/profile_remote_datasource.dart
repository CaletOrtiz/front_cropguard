// datasources/profile_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;
  ProfileRemoteDataSourceImpl(this.client);

  @override
  Future<UserProfileModel> getProfile() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) throw const AuthException('No hay sesión activa');

    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    final user = await client
        .from('users')
        .select()
        .eq('id', authUser.id)
        .limit(1)
        .maybeSingle();
    final profile = await client
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .limit(1)
        .maybeSingle();

    final userData = {
      ...?user,
      'id': authUser.id,
      'email': user?['email'] ?? authUser.email ?? metadata['email'],
      'full_name':
          user?['full_name'] ?? metadata['full_name'] ?? metadata['name'] ?? '',
      'avatar_url':
          user?['avatar_url'] ?? metadata['avatar_url'] ?? metadata['picture'],
    };

    return UserProfileModel.fromRows(userData, profile);
  }
}
