import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/auth/domain/entities/app_user.dart';
import 'package:kroppi/features/auth/domain/entities/sign_up_params.dart';
import 'package:kroppi/features/auth/domain/repositories/auth_repository.dart';
import 'package:kroppi/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:kroppi/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_event.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_state.dart';

const _testUser = AppUser(
  id: 'user-1',
  email: 'agricultor@correo.com',
  fullName: 'Agricultor Prueba',
  municipality: 'Valledupar',
  department: 'Cesar',
);

const _signUp = SignUpParams(
  fullName: 'Agricultor Prueba',
  email: ' agricultor@correo.com ',
  password: '123456',
  phoneNumber: '3001234567',
  municipality: 'Valledupar',
);

void main() {
  group('AuthBloc', () {
    test('emits authenticated with profile after Google sign-in', () async {
      final bloc = _createBloc();
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having((s) => s.user, 'user', _testUser),
        ]),
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

    test('emits authenticated with profile after email sign-in', () async {
      final bloc = _createBloc();
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having((s) => s.user, 'user', _testUser),
        ]),
      );

      bloc.add(
        const AuthEmailSignInRequested(
          email: 'agricultor@correo.com',
          password: '123456',
        ),
      );

      await expectedStates;
      await bloc.close();
    });

    test('emits failure when email sign-in fails', () async {
      final bloc = _createBloc(signInError: StateError('invalid credentials'));
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (state) => state.message,
            'message',
            contains('invalid credentials'),
          ),
        ]),
      );

      bloc.add(
        const AuthEmailSignInRequested(
          email: 'agricultor@correo.com',
          password: 'mala',
        ),
      );

      await expectedStates;
      await bloc.close();
    });

    test('sends every form field to the repository on sign-up', () async {
      final repository = _FakeAuthRepository();
      final bloc = _createBloc(repository: repository);
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthAuthenticated>()]),
      );

      bloc.add(const AuthEmailSignUpRequested(_signUp));

      await expectedStates;
      expect(repository.lastSignUp, _signUp);
      await bloc.close();
    });

    test('asks for email confirmation when sign-up returns no session',
        () async {
      final bloc = _createBloc(signUpNeedsConfirmation: true);
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthSignUpConfirmationRequired>().having(
            (state) => state.email,
            'email',
            'agricultor@correo.com',
          ),
        ]),
      );

      bloc.add(const AuthEmailSignUpRequested(_signUp));

      await expectedStates;
      await bloc.close();
    });

    test('emits unauthenticated when there is no stored session', () async {
      final bloc = _createBloc(currentUser: null);
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthUnauthenticated>()]),
      );

      bloc.add(const AuthSessionCheckRequested());

      await expectedStates;
      await bloc.close();
    });

    test('emits authenticated when a stored session exists', () async {
      final bloc = _createBloc();
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthAuthenticated>()]),
      );

      bloc.add(const AuthSessionCheckRequested());

      await expectedStates;
      await bloc.close();
    });

    test('replaces the session user when the profile is updated', () async {
      final bloc = _createBloc();
      const updated = AppUser(
        id: 'user-1',
        email: 'agricultor@correo.com',
        fullName: 'Agricultor Prueba',
        role: 'AGRONOMIST',
        municipality: 'Codazzi',
        department: 'Cesar',
        phoneNumber: '3001234567',
      );
      final expectedStates = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthAuthenticated>().having((s) => s.user, 'user', updated),
        ]),
      );

      bloc.add(const AuthUserUpdated(updated));

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

AuthBloc _createBloc({
  _FakeAuthRepository? repository,
  Object? signInError,
  bool signUpNeedsConfirmation = false,
  AppUser? currentUser = _testUser,
}) {
  final repo =
      repository ??
      _FakeAuthRepository(
        signInError: signInError,
        signUpNeedsConfirmation: signUpNeedsConfirmation,
        currentUser: currentUser,
      );
  return AuthBloc(
    signInWithGoogle: SignInWithGoogleUsecase(repo),
    signInWithEmail: SignInWithEmailUsecase(repo),
    signUpWithEmail: SignUpWithEmailUsecase(repo),
    getCurrentUser: GetCurrentUserUsecase(repo),
    signOut: SignOutUsecase(repo),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.signInError,
    this.signUpNeedsConfirmation = false,
    this.currentUser = _testUser,
  });

  final Object? signInError;
  final bool signUpNeedsConfirmation;
  final AppUser? currentUser;

  SignUpParams? lastSignUp;

  @override
  Future<AppUser> signInWithGoogle() async {
    final error = signInError;
    if (error != null) throw error;
    return _testUser;
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final error = signInError;
    if (error != null) throw error;
    return _testUser;
  }

  @override
  Future<AppUser?> signUpWithEmail(SignUpParams params) async {
    lastSignUp = params;
    return signUpNeedsConfirmation ? null : _testUser;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser?> getCurrentUser() async => currentUser;
}
