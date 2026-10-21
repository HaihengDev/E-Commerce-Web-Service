import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:merchant_service/services/merchant_service.dart';
import 'package:merchant_service/security/token_claims.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final service = MerchantService();
  final method = switch (context.request.method) {
    HttpMethod.get => 'GET',
    HttpMethod.put => 'PUT',
    HttpMethod.patch => 'PATCH',
    HttpMethod.delete => 'DELETE',
    _ => null,
  };
  if (method == null) return _methodNotAllowed();
  try {
    final authorization = context.request.headers['authorization'];
    if (method != 'GET') {
      final claims = TokenClaims.fromAuthorization(authorization);
      if (claims == null) return _unauthorized();
      if (claims.role != 'merchant') {
        return Response.json(
          statusCode: 403,
          body: {'message': 'Only merchants can manage products.'},
        );
      }
    }
    final body = method == 'PUT' || method == 'PATCH'
        ? await _readJson(context.request)
        : null;
    final result = await service.products(
      method,
      id: id,
      body: body,
      authorization: authorization,
    );
    return Response.json(statusCode: result.statusCode, body: result.body);
  } on FormatException catch (error) {
    return Response.json(statusCode: 400, body: {'message': error.message});
  } catch (error) {
    return Response.json(
      statusCode: 502,
      body: {
        'message': 'Product service unavailable.',
        'error': error.toString(),
      },
    );
  }
}

Response _unauthorized() => Response.json(
  statusCode: 401,
  body: {'message': 'A valid bearer token is required.'},
);

Future<Map<String, dynamic>> _readJson(Request request) async {
  final value = jsonDecode(await request.body());
  if (value is! Map<String, dynamic>)
    throw const FormatException('Request body must be a JSON object.');
  return value;
}

Response _methodNotAllowed() =>
    Response.json(statusCode: 405, body: {'message': 'Method not allowed.'});
