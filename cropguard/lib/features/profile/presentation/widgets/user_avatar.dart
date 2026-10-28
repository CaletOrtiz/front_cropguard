import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

/// Foto de perfil redonda. Prioriza [bytes] (foto recién elegida), luego
/// [imageUrl] y, si no hay ninguna o falla la carga, muestra el ícono.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.imageUrl, this.bytes, this.size = 88});

  final String? imageUrl;
  final Uint8List? bytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.person_rounded,
      size: size * 0.5,
      color: AppColors.primary,
    );

    Widget content = fallback;
    if (bytes != null) {
      content = Image.memory(bytes!, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      content = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: content,
    );
  }
}
