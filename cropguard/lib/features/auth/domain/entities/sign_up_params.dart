import 'package:equatable/equatable.dart';

/// Datos del formulario de registro. Todo lo que no es correo/contraseña
/// termina en `profiles` (lo copia el trigger handle_new_user).
class SignUpParams extends Equatable {
  const SignUpParams({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.municipality,
    this.department = 'Cesar',
    this.role = 'FARMER',
  });

  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? municipality;
  final String? department;

  /// Solo FARMER o AGRONOMIST: el trigger ignora cualquier otro valor.
  final String role;

  @override
  List<Object?> get props => [
    fullName,
    email,
    password,
    phoneNumber,
    municipality,
    department,
    role,
  ];
}
