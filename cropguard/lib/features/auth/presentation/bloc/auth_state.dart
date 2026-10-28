import 'package:equatable/equatable.dart';
import 'package:kroppi/features/auth/domain/entities/app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// El registro se hizo, pero Supabase espera que el usuario confirme el
/// correo antes de poder iniciar sesión.
final class AuthSignUpConfirmationRequired extends AuthState {
  const AuthSignUpConfirmationRequired(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
