import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:merchant_service/services/response_cache.dart';

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
    String? authorization,
  }) async {
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final configuredUrl = env[baseUrl] ?? _defaultUrl(baseUrl);
    final normalizedUrl = configuredUrl.replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse(normalizedUrl);
    final requestUri = id == null
        ? uri
        : uri.replace(path: '${uri.path}/${Uri.encodeComponent(id)}');
    final service = switch (baseUrl) {
      'PRODUCT_SERVICE_URL' => 'products',
      'CATEGORY_SERVICE_URL' => 'categories',
      _ => null,
    };
    final cacheKey = service == null
        ? null
        : 'gateway:$service:${await ResponseCache.version(service)}:$requestUri';
    if (method == 'GET' && authorization == null && cacheKey != null) {
      final cached = await ResponseCache.get(cacheKey);
      if (cached != null) {
        return ServiceResponse(cached.statusCode, cached.body);
      }
    }
    final request = await _client.openUrl(method, requestUri);
    request.headers.contentType = ContentType.json;
    if (authorization != null) {
      request.headers.set(HttpHeaders.authorizationHeader, authorization);
    }
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
    if (method == 'GET' &&
        authorization == null &&
        response.statusCode == 200 &&
        cacheKey != null) {
      await ResponseCache.set(cacheKey, response.statusCode, decoded);
    } else if (method != 'GET' &&
        service != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      await ResponseCache.invalidate(service);
    }
    return ServiceResponse(response.statusCode, decoded);
  }

  String _defaultUrl(String key) => switch (key) {
    'PRODUCT_SERVICE_URL' => 'http://localhost:8000',
    'CATEGORY_SERVICE_URL' => 'http://localhost:8001/categories',
    'AUTH_SERVICE_URL' => 'http://localhost:8003',
    'ORDER_SERVICE_URL' => 'http://localhost:8004/orders',
    _ => throw ArgumentError('Unsupported service URL: $key'),
  };
}
