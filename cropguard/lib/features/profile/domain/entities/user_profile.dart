// entities/user_profile.dart
class UserProfile {
  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? role;
  final String? municipality;
  final String? department;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.phoneNumber,
    this.role,
    this.municipality,
    this.department,
  });
}
