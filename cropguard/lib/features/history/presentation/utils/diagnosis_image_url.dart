const diagnosisImagesBucket = 'diagnosticos';

String? diagnosisImageObjectPath(
  String imageUrl, {
  required String supabaseBaseUrl,
  required String apiBaseUrl,
}) {
  final uri = Uri.tryParse(imageUrl);
  if (uri == null) return null;

  final supabaseUri = Uri.tryParse(supabaseBaseUrl);
  final apiUri = Uri.tryParse(apiBaseUrl);
  final isSupabaseUrl =
      uri.hasScheme &&
      supabaseUri != null &&
      uri.host == supabaseUri.host &&
      uri.port == supabaseUri.port;
  final isApiUrl =
      uri.hasScheme &&
      apiUri != null &&
      uri.host == apiUri.host &&
      uri.port == apiUri.port;

  var pathSegments = uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();

  if (isSupabaseUrl) {
    final objectIndex = pathSegments.indexOf('object');
    if (objectIndex < 2 ||
        pathSegments.length <= objectIndex + 2 ||
        pathSegments[objectIndex - 2] != 'storage' ||
        pathSegments[objectIndex - 1] != 'v1' ||
        !{
          'public',
          'sign',
          'authenticated',
        }.contains(pathSegments[objectIndex + 1]) ||
        pathSegments[objectIndex + 2] != diagnosisImagesBucket) {
      return null;
    }
    pathSegments = pathSegments.sublist(objectIndex + 3);
  } else if (uri.hasScheme && !isApiUrl) {
    return null;
  } else if (pathSegments.firstOrNull == diagnosisImagesBucket) {
    pathSegments = pathSegments.sublist(1);
  }

  if (pathSegments.isEmpty ||
      pathSegments.any(
        (segment) => segment == '.' || segment == '..' || segment.isEmpty,
      )) {
    return null;
  }

  return pathSegments.join('/');
}
