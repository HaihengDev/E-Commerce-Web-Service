import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:merchant_service/security/token_claims.dart';
import 'package:merchant_service/services/merchant_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final authorization = context.request.headers['authorization'];
  final claims = TokenClaims.fromAuthorization(authorization);
  if (claims == null) {
    return Response.json(
      statusCode: 401,
      body: {'message': 'A valid bearer token is required.'},
    );
  }
  if (claims.role != 'user') {
    return Response.json(
      statusCode: 403,
      body: {'message': 'Only normal users can create or view orders.'},
    );
  }
  final method = switch (context.request.method) {
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    _ => null,
  };
  if (method == null) {
    return Response.json(
      statusCode: 405,
      body: {'message': 'Method not allowed.'},
    );
  }
  try {
    Map<String, dynamic>? body;
    if (method == 'POST') {
      final decoded = jsonDecode(await context.request.body());
      if (decoded is! Map<String, dynamic>) {
        return Response.json(
          statusCode: 400,
          body: {'message': 'Request body must be a JSON object.'},
        );
      }
      body = decoded;
    }
    final result = await MerchantService().orders(
      method,
      body: body,
      authorization: authorization,
    );
    return Response.json(statusCode: result.statusCode, body: result.body);
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } catch (error) {
    return Response.json(
      statusCode: 502,
      body: {
        'message': 'Order service unavailable.',
        'error': error.toString(),
      },
    );
  }
}
