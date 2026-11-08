import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/history/presentation/utils/diagnosis_image_url.dart';

void main() {
  const supabaseBaseUrl = 'https://project.supabase.co';
  const apiBaseUrl = 'http://127.0.0.1:8000';

  test('extracts object path from a relative image path', () {
    final path = diagnosisImageObjectPath(
      'user-id/diagnosis-id.jpg',
      supabaseBaseUrl: supabaseBaseUrl,
      apiBaseUrl: apiBaseUrl,
    );

    expect(path, 'user-id/diagnosis-id.jpg');
  });

  test('extracts object path from a backend URL', () {
    final path = diagnosisImageObjectPath(
      '$apiBaseUrl/user-id/diagnosis-id.jpg',
      supabaseBaseUrl: supabaseBaseUrl,
      apiBaseUrl: apiBaseUrl,
    );

    expect(path, 'user-id/diagnosis-id.jpg');
  });

  test('extracts object path from a public Supabase Storage URL', () {
    const url =
        'https://project.supabase.co/storage/v1/object/public/'
        'diagnosticos/user-id/diagnosis-id.jpg';

    final path = diagnosisImageObjectPath(
      url,
      supabaseBaseUrl: supabaseBaseUrl,
      apiBaseUrl: apiBaseUrl,
    );

    expect(path, 'user-id/diagnosis-id.jpg');
  });

  test('rejects Supabase URLs for another bucket', () {
    final path = diagnosisImageObjectPath(
      'https://project.supabase.co/storage/v1/object/public/avatars/photo.jpg',
      supabaseBaseUrl: supabaseBaseUrl,
      apiBaseUrl: apiBaseUrl,
    );

    expect(path, isNull);
  });
}
