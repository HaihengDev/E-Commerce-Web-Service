import 'dart:convert';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:http/http.dart' as http;

class InventoryClient {
  InventoryClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> reserve({
    required String orderId,
    required String userId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _post('reserve', {
      'order_id': orderId,
      'user_id': userId,
      'items': items,
    });
    if (response.statusCode == 409) {
      final body = jsonDecode(response.body);
      throw InventoryUnavailable(
        body is Map && body['product_id'] is String
            ? body['product_id'] as String
            : null,
      );
    }
    if (response.statusCode != 200) {
      throw StateError('Product service could not reserve inventory.');
    }
  }

  Future<void> release({
    required String orderId,
    required String userId,
  }) async {
    final response = await _post('release', {
      'order_id': orderId,
      'user_id': userId,
    });
    if (response.statusCode != 200) {
      throw StateError('Product service could not release inventory.');
    }
  }

  Future<http.Response> _post(String action, Map<String, dynamic> body) async {
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final baseUrl = env['PRODUCT_SERVICE_URL'] ?? 'http://localhost:8086';
    final token = env['INTERNAL_SERVICE_TOKEN'];
    if (token == null || token.length < 32) {
      throw StateError('INTERNAL_SERVICE_TOKEN is not configured.');
    }
    final uri = Uri.parse(baseUrl).resolve('/internal/inventory/$action');
    return _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-internal-service-token': token,
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
  }

  void close() => _client.close();
}

class InventoryUnavailable implements Exception {
  const InventoryUnavailable(this.productId);
  final String? productId;
}
