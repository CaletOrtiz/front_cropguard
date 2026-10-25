import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.signInWithGoogle, required this.signOut})
    : super(const AuthInitial()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final SignInWithGoogleUsecase signInWithGoogle;
  final SignOutUsecase signOut;

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await signInWithGoogle();
      emit(const AuthAuthenticated());
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
