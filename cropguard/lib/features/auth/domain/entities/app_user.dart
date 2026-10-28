import 'package:equatable/equatable.dart';

/// Usuario autenticado + los datos de su fila en `public.profiles`.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'FARMER',
    this.phoneNumber,
    this.municipality,
    this.department,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;

  /// FARMER, AGRONOMIST o ADMIN (columna `profiles.role`).
  final String role;
  final String? phoneNumber;
  final String? municipality;
  final String? department;
  final String? avatarUrl;

  String get roleLabel => switch (role) {
    'AGRONOMIST' => 'Agrónomo',
    'ADMIN' => 'Administrador',
    _ => 'Agricultor',
  };

  /// "Valledupar, Cesar", solo "Cesar", o null si no hay ubicación.
  String? get locationLabel {
    final parts = [
      municipality,
      department,
    ].whereType<String>().where((p) => p.trim().isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    role,
    phoneNumber,
    municipality,
    department,
    avatarUrl,
  ];
}
