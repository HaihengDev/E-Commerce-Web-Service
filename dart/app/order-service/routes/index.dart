import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:order_service/config/db.dart';
import 'package:order_service/repositories/order_repository.dart';
import 'package:order_service/security/token_claims.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final claims = TokenClaims.fromAuthorization(
      context.request.headers['authorization'],
    );
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
    final repository = OrderRepository(await Database.connection);
    switch (context.request.method) {
      case HttpMethod.get:
        return Response.json(body: await repository.findByUser(claims.subject));
      case HttpMethod.post:
        final decoded = jsonDecode(await context.request.body());
        if (decoded is! Map<String, dynamic> || decoded['items'] is! List) {
          return _badRequest('items must be a non-empty list.');
        }
        final rawItems = decoded['items'] as List;
        if (rawItems.isEmpty || rawItems.length > 50) {
          return _badRequest('Order must contain between 1 and 50 items.');
        }
        final items = <Map<String, dynamic>>[];
        for (final raw in rawItems) {
          if (raw is! Map ||
              raw['product_id'] is! String ||
              (raw['product_id'] as String).trim().isEmpty ||
              raw['quantity'] is! int ||
              (raw['quantity'] as int) < 1 ||
              (raw['quantity'] as int) > 100) {
            return _badRequest(
              'Each item needs a product_id and quantity from 1 to 100.',
            );
          }
          items.add({
            'product_id': (raw['product_id'] as String).trim(),
            'quantity': raw['quantity'] as int,
          });
        }
        final order = await repository.create(claims.subject, items);
        return Response.json(statusCode: 201, body: order);
      default:
        return Response.json(
          statusCode: 405,
          body: {'message': 'Method not allowed.'},
        );
    }
  } on FormatException {
    return _badRequest('Invalid JSON.');
  } catch (error) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Internal server error.', 'error': error.toString()},
    );
  }
}

Response _badRequest(String message) =>
    Response.json(statusCode: 400, body: {'message': message});
