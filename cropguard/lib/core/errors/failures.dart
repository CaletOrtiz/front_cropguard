// core/error/failures.dart
abstract class Failure {
  const Failure(this.message);
  final String message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CancelledFailure extends Failure {
  const CancelledFailure() : super('Inicio de sesión cancelado');
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
