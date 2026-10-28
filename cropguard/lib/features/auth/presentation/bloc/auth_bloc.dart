import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.signInWithGoogle,
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.getCurrentUser,
    required this.signOut,
  }) : super(const AuthInitial()) {
    on<AuthSessionCheckRequested>(_onSessionCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthEmailSignInRequested>(_onEmailSignInRequested);
    on<AuthEmailSignUpRequested>(_onEmailSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final SignInWithGoogleUsecase signInWithGoogle;
  final SignInWithEmailUsecase signInWithEmail;
  final SignUpWithEmailUsecase signUpWithEmail;
  final GetCurrentUserUsecase getCurrentUser;
  final SignOutUsecase signOut;

  Future<void> _onSessionCheckRequested(
    AuthSessionCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await getCurrentUser();
      emit(
        user == null
            ? const AuthUnauthenticated()
            : AuthAuthenticated(user: user),
      );
    } catch (_) {
      // Sin red o sesión inválida: se muestra la pantalla de bienvenida.
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithGoogle();
      emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onEmailSignInRequested(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onEmailSignUpRequested(
    AuthEmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signUpWithEmail(event.params);
      emit(
        user == null
            ? AuthSignUpConfirmationRequired(event.params.email.trim())
            : AuthAuthenticated(user: user),
      );
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await signOut();
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }
}
