import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/auth/domain/repositories/auth_repository.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_event.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('AuthBloc', () {
    test('emits authenticated after Google sign-in succeeds', () async {
      final bloc = _createBloc();
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthAuthenticated>()]),
      );

      bloc.add(const AuthGoogleSignInRequested());

      await expectedStates;
      await bloc.close();
    });

    test('emits failure when Google sign-in fails', () async {
      final bloc = _createBloc(signInError: StateError('network unavailable'));
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (state) => state.message,
            'message',
            contains('network unavailable'),
          ),
        ]),
      );

      bloc.add(const AuthGoogleSignInRequested());

      await expectedStates;
      await bloc.close();
    });

    test('emits unauthenticated after sign-out succeeds', () async {
      final bloc = _createBloc();
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthUnauthenticated>()]),
      );

      bloc.add(const AuthSignOutRequested());

      await expectedStates;
      await bloc.close();
    });
  });
}

AuthBloc _createBloc({Object? signInError}) {
  final repository = _FakeAuthRepository(signInError: signInError);
  return AuthBloc(
    signInWithGoogle: SignInWithGoogleUsecase(repository),
    signOut: SignOutUsecase(repository),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.signInError});

  final Object? signInError;

  @override
  Future<void> signInWithGoogle() async {
    final error = signInError;
    if (error != null) throw error;
  }

  @override
  Future<void> signOut() async {}
}
