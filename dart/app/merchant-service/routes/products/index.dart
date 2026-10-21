import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:merchant_service/services/merchant_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final service = MerchantService();
  final method = switch (context.request.method) {
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    _ => null,
  };
  if (method == null) return _methodNotAllowed();
  try {
    final body = method == 'POST' ? await _readJson(context.request) : null;
    return _forward(await service.products(method, body: body));
  } on FormatException catch (error) {
    return _badRequest(error.message);
  } catch (error) {
    return _gatewayError(error);
  }
}

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
