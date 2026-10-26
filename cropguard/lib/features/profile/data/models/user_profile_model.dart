// models/user_profile_model.dart
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    super.email,
    super.avatarUrl,
    super.phoneNumber,
    super.role,
    super.municipality,
    super.department,
  });

  factory UserProfileModel.fromRows(
    Map<String, dynamic> user,
    Map<String, dynamic>? profile,
  ) {
    return UserProfileModel(
      id: user['id'] as String,
      email: user['email'] as String?,
      fullName: (profile?['full_name'] ?? user['full_name'] ?? '') as String,
      avatarUrl: (profile?['avatar_url'] ?? user['avatar_url']) as String?,
      phoneNumber: profile?['phone_number'] as String?,
      role: profile?['role'] as String?,
      municipality: profile?['municipality'] as String?,
      department: profile?['department'] as String?,
    );
  }
}
