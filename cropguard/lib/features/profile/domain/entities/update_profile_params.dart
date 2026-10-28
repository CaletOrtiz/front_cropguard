import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Foto elegida de la galería, lista para subir.
class AvatarUpload extends Equatable {
  const AvatarUpload({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;

  /// image/jpeg, image/png o image/webp.
  final String contentType;

  @override
  List<Object?> get props => [bytes, fileName, contentType];
}

/// Campos editables en "Datos personales". El nombre y el correo no se
/// editan desde esta pantalla.
class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    required this.municipality,
    required this.role,
    this.phoneNumber,
    this.avatar,
    this.previousAvatarUrl,
  });

  /// Null borra el celular.
  final String? phoneNumber;
  final String municipality;

  /// FARMER o AGRONOMIST.
  final String role;

  /// Si es null, la foto actual no cambia.
  final AvatarUpload? avatar;

  /// Foto anterior: se borra del Storage cuando se sube una nueva.
  final String? previousAvatarUrl;

  @override
  List<Object?> get props => [
    phoneNumber,
    municipality,
    role,
    avatar,
    previousAvatarUrl,
  ];
}
