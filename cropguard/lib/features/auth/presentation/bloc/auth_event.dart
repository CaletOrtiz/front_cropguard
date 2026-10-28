import 'package:equatable/equatable.dart';
import 'package:kroppi/features/auth/domain/entities/app_user.dart';
import 'package:kroppi/features/auth/domain/entities/sign_up_params.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Se lanza al abrir la app para saber si ya hay una sesión guardada.
final class AuthSessionCheckRequested extends AuthEvent {
  const AuthSessionCheckRequested();
}

final class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

final class AuthEmailSignInRequested extends AuthEvent {
  const AuthEmailSignInRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthEmailSignUpRequested extends AuthEvent {
  const AuthEmailSignUpRequested(this.params);

  final SignUpParams params;

  @override
  List<Object?> get props => [params];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// El perfil cambió (por ejemplo, se editaron los datos personales): se
/// reemplaza el usuario de la sesión sin volver a iniciar sesión.
final class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}
