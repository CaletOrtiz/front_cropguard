import 'package:flutter/material.dart';
import 'package:kroppi/core/network/api/fastapi_client.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart'
    as app_supabase;
import 'package:kroppi/core/widgets/crop_visual.dart';
import 'package:kroppi/features/history/presentation/utils/diagnosis_image_url.dart';

class DiagnosisPhoto extends StatefulWidget {
  const DiagnosisPhoto({
    super.key,
    required this.imageUrl,
    required this.cropId,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.iconSize,
  });

  final String? imageUrl;
  final String cropId;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final double iconSize;

  @override
  State<DiagnosisPhoto> createState() => _DiagnosisPhotoState();
}

class _DiagnosisPhotoState extends State<DiagnosisPhoto> {
  Future<String?>? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = _createImageUrl();
  }

  @override
  void didUpdateWidget(covariant DiagnosisPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageUrl = _createImageUrl();
    }
  }

  Future<String?> _createImageUrl() async {
    final imageUrl = widget.imageUrl?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return null;

    final objectPath = diagnosisImageObjectPath(
      imageUrl,
      supabaseBaseUrl: app_supabase.SupabaseClient.baseUrl,
      apiBaseUrl: FastApiClient.baseUrl,
    );
    if (objectPath != null) {
      final client = app_supabase.SupabaseClient.client;
      if (client.auth.currentSession == null) {
        throw StateError('Se requiere una sesión para cargar la foto.');
      }

      return client.storage
          .from(diagnosisImagesBucket)
          .createSignedUrl(objectPath, 3600);
    }

    final externalUri = Uri.tryParse(imageUrl);
    if (externalUri != null &&
        (externalUri.scheme == 'http' || externalUri.scheme == 'https')) {
      return imageUrl;
    }
    throw StateError('La URL de imagen del diagnóstico no es válida.');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) return _placeholder();

    return FutureBuilder<String?>(
      future: imageUrl,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(
            '[HISTORY IMAGE] Could not create signed URL: ${snapshot.error}',
          );
          return _placeholder();
        }
        if (!snapshot.hasData) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: Image.network(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('[HISTORY IMAGE] Could not render photo: $error');
              return _placeholder();
            },
          ),
        );
      },
    );
  }

  Widget _placeholder() => CropVisual(
    cropId: widget.cropId,
    width: widget.width,
    height: widget.height,
    borderRadius: widget.borderRadius,
    iconSize: widget.iconSize,
  );
}
