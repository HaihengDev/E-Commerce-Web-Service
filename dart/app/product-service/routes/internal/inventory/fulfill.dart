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
        decoded['user_id'] is! String) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'order_id and user_id are required.'},
      );
    }
    final issue = await InventoryService(await Database.connection)
        .issueFakeSerialCodes(
          orderId: decoded['order_id'] as String,
          userId: decoded['user_id'] as String,
        );
    if (issue == null) {
      return Response.json(
        statusCode: 409,
        body: {'message': 'Inventory is not reserved for this order.'},
      );
    }
    return Response.json(
      body: {
        'order_id': issue['order_id'],
        'user_id': issue['user_id'],
        'items': issue['items'],
      },
    );
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } catch (_) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Could not issue serial codes.'},
    );
  }
}
