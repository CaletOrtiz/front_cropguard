import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failures.dart';

/// Ejecuta una operación de la capa data y traduce cualquier excepción
/// (Supabase Auth, Postgrest, Storage, red) a un [Failure] con mensaje en
/// español. Los repositorios envuelven sus llamadas con esta función.
Future<T> guardCall<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on Failure {
    rethrow;
  } on AuthRetryableFetchException {
    throw const NetworkFailure();
  } on AuthException catch (e) {
    throw AuthFailure(_authMessage(e.message));
  } on PostgrestException catch (e) {
    throw ServerFailure(_dbMessage(e));
  } on StorageException catch (e) {
    throw ServerFailure('No se pudo subir la imagen: ${e.message}');
  } on SocketException {
    throw const NetworkFailure();
  } catch (_) {
    throw const UnknownFailure(
      'Ocurrió un error inesperado. Inténtalo de nuevo.',
    );
  }
}

String _authMessage(String raw) {
  final m = raw.toLowerCase();
  if (m.contains('invalid login credentials')) {
    return 'Correo o contraseña incorrectos.';
  }
  if (m.contains('email not confirmed')) {
    return 'Confirma tu correo antes de iniciar sesión.';
  }
  if (m.contains('already registered') || m.contains('already been registered')) {
    return 'Este correo ya tiene una cuenta.';
  }
  if (m.contains('password should be') || m.contains('weak password')) {
    return 'La contraseña es muy débil (mínimo 6 caracteres).';
  }
  if (m.contains('rate limit') || m.contains('too many')) {
    return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
  }
  return raw;
}

String _dbMessage(PostgrestException e) {
  if (e.code == '42501') return 'No tienes permiso para realizar esta acción.';
  return e.message;
}
