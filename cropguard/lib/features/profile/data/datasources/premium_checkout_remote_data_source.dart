import 'package:dio/dio.dart';
import 'package:kroppi/core/network/api/api_endpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PremiumCheckoutRemoteDataSource {
  const PremiumCheckoutRemoteDataSource(this.dio, this.supabaseClient);

  final Dio dio;
  final SupabaseClient supabaseClient;

  Future<Uri> createCheckout() async {
    final token = supabaseClient.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Tu sesión expiró. Inicia sesión de nuevo.');
    }

    final response = await dio.post<Object?>(
      ApiEndpoints.createPayment,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = response.data;
    if (data is! Map || data['checkout_url'] is! String) {
      throw const FormatException(
        'El servidor no devolvió una URL de pago válida.',
      );
    }

    final checkoutUri = Uri.tryParse(data['checkout_url'] as String);
    if (checkoutUri == null ||
        !checkoutUri.isAbsolute ||
        !checkoutUri.hasAuthority ||
        (checkoutUri.scheme != 'https' && checkoutUri.scheme != 'http')) {
      throw const FormatException(
        'El servidor devolvió una URL de pago no válida.',
      );
    }

    return checkoutUri;
  }
}
