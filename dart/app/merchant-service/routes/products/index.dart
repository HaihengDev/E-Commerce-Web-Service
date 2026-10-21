import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:merchant_service/services/merchant_service.dart';
import 'package:merchant_service/security/token_claims.dart';

Future<Response> onRequest(RequestContext context) async {
  final service = MerchantService();
  final method = switch (context.request.method) {
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    _ => null,
  };
  if (method == null) return _methodNotAllowed();
  try {
    final authorization = context.request.headers['authorization'];
    if (method == 'POST') {
      final claims = TokenClaims.fromAuthorization(authorization);
      if (claims == null) return _unauthorized();
      if (claims.role != 'merchant')
        return _forbidden('Only merchants can create products.');
    }
    final body = method == 'POST' ? await _readJson(context.request) : null;
    return _forward(
      await service.products(method, body: body, authorization: authorization),
    );
  } on FormatException catch (error) {
    return _badRequest(error.message);
  } catch (error) {
    return _gatewayError(error);
  }
}

Response _unauthorized() => Response.json(
  statusCode: 401,
  body: {'message': 'A valid bearer token is required.'},
);
Response _forbidden(String message) =>
    Response.json(statusCode: 403, body: {'message': message});

Future<Map<String, dynamic>> _readJson(Request request) async {
  final value = jsonDecode(await request.body());
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Request body must be a JSON object.');
  }
  return value;
}

Response _forward(dynamic result) =>
    Response.json(statusCode: result.statusCode as int, body: result.body);
Response _badRequest(String message) =>
    Response.json(statusCode: 400, body: {'message': message});
Response _methodNotAllowed() =>
    Response.json(statusCode: 405, body: {'message': 'Method not allowed.'});
Response _gatewayError(Object error) => Response.json(
  statusCode: 502,
  body: {'message': 'Product service unavailable.', 'error': error.toString()},
);
