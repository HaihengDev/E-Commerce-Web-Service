import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;

class ServiceResponse {
  const ServiceResponse(this.statusCode, this.body);

  final int statusCode;
  final dynamic body;
}

class ServiceClient {
  ServiceClient({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  Future<ServiceResponse> send(
    String baseUrl,
    String method, {
    String? id,
    Map<String, dynamic>? body,
  }) async {
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final configuredUrl = env[baseUrl] ?? _defaultUrl(baseUrl);
    final normalizedUrl = configuredUrl.replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse(normalizedUrl);
    final requestUri = id == null
        ? uri
        : uri.replace(path: '${uri.path}/${Uri.encodeComponent(id)}');
    final request = await _client.openUrl(method, requestUri);
    request.headers.contentType = ContentType.json;
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    dynamic decoded;
    if (responseBody.isNotEmpty) {
      try {
        decoded = jsonDecode(responseBody);
      } on FormatException {
        decoded = {'message': responseBody};
      }
    }
    return ServiceResponse(response.statusCode, decoded);
  }

  String _defaultUrl(String key) => switch (key) {
    'PRODUCT_SERVICE_URL' => 'http://localhost:8000',
    'CATEGORY_SERVICE_URL' => 'http://localhost:8001/categories',
    _ => throw ArgumentError('Unsupported service URL: $key'),
  };
}
