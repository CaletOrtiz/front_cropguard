import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.role,
    super.phoneNumber,
    super.municipality,
    super.department,
    super.avatarUrl,
  });

  /// [row] es una fila de `public.profiles`; el correo viene de auth.users
  /// porque `profiles` no lo guarda.
  factory AppUserModel.fromProfile(
    Map<String, dynamic> row, {
    required String email,
  }) {
    String? text(String key) {
      final value = row[key]?.toString().trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    final fallbackName = email.contains('@')
        ? email.split('@').first
        : 'Agricultor';

    return AppUserModel(
      id: row['id'].toString(),
      email: email,
      fullName: text('full_name') ?? fallbackName,
      role: text('role') ?? 'FARMER',
      phoneNumber: text('phone_number'),
      municipality: text('municipality'),
      department: text('department'),
      avatarUrl: text('avatar_url'),
    );
  }
}
