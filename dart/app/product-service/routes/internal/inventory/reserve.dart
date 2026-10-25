import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:app/config/db.dart';
import 'package:app/security/internal_service_auth.dart';
import 'package:app/services/inventory_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'message': 'Method not allowed.'},
    );
  }
  if (!hasValidInternalServiceToken(context.request.headers)) {
    return Response.json(statusCode: 401, body: {'message': 'Unauthorized.'});
  }

  try {
    final decoded = jsonDecode(await context.request.body());
    if (decoded is! Map<String, dynamic> ||
        decoded['order_id'] is! String ||
        decoded['user_id'] is! String ||
        decoded['items'] is! List) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Invalid reservation request.'},
      );
    }
    final rawItems = decoded['items'] as List;
    if (rawItems.isEmpty || rawItems.any((item) => !_isValidItem(item))) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Invalid reservation items.'},
      );
    }
    final items = rawItems
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final result = await InventoryService(await Database.connection).reserve(
      orderId: decoded['order_id'] as String,
      userId: decoded['user_id'] as String,
      items: items,
    );
    if (result.reserved) {
      return Response.json(body: {'reserved': true});
    }
    if (result.productId != null) {
      return Response.json(
        statusCode: 409,
        body: {
          'message': 'Insufficient stock or product not found.',
          'product_id': result.productId,
        },
      );
    }
    return Response.json(
      statusCode: 409,
      body: {'message': 'Order inventory reservation already exists.'},
    );
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } catch (_) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Could not reserve inventory.'},
    );
  }
}

bool _isValidItem(Object? value) {
  if (value is! Map) return false;
  final item = Map<Object?, Object?>.from(value);
  final productId = item['product_id'];
  final quantity = item['quantity'];
  return productId is String &&
      productId.trim().isNotEmpty &&
      quantity is int &&
      quantity > 0 &&
      quantity <= 100;
}
