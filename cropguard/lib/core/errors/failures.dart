/// Errores de dominio que viajan desde la capa data hasta los bloc/cubit.
///
/// Implementan [Exception] y su toString() devuelve el mensaje, así que
/// `error.toString()` ya es un texto apto para mostrar al usuario.
abstract class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CancelledFailure extends Failure {
  const CancelledFailure() : super('Inicio de sesión cancelado');
}

class NetworkFailure extends Failure {
  const NetworkFailure()
    : super('Sin conexión. Revisa tu internet e inténtalo de nuevo.');
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
