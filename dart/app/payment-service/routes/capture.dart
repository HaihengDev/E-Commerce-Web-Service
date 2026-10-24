import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:payment_service/config/db.dart';
import 'package:payment_service/security/token_claims.dart';
import 'package:payment_service/services/payment_provider.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post)
    return Response.json(
      statusCode: 405,
      body: {'message': 'Method not allowed.'},
    );
  try {
    final claims = TokenClaims.fromAuthorization(
      context.request.headers['authorization'],
    );
    if (claims == null)
      return Response.json(
        statusCode: 401,
        body: {'message': 'A valid bearer token is required.'},
      );
    if (claims.role != 'user')
      return Response.json(
        statusCode: 403,
        body: {'message': 'Only users can capture payments.'},
      );
    final body = jsonDecode(await context.request.body());
    if (body is! Map<String, dynamic> || body['paypal_order_id'] is! String)
      return Response.json(
        statusCode: 400,
        body: {'message': 'paypal_order_id is required.'},
      );
    final db = await Database.connection;
    final payment = await db
        .collection('payments')
        .findOne(
          where
              .eq('provider', 'paypal')
              .eq('paypal_order_id', body['paypal_order_id'])
              .eq('user_id', claims.subject),
        );
    if (payment == null)
      return Response.json(
        statusCode: 404,
        body: {'message': 'PayPal checkout not found.'},
      );
    final client = http.Client();
    try {
      final result = await PaymentProvider(client)
          .capturePayPalOrder(body['paypal_order_id'] as String);
      if (result['status'] == 'COMPLETED') {
        await db
            .collection('payments')
            .updateOne(
              where.eq('paypal_order_id', body['paypal_order_id']),
              modify.set('status', 'paid'),
            );
        await db
            .collection('orders')
            .updateOne(
              where
                  .eq('order_id', result['order_id'])
                  .eq('user_id', claims.subject),
              modify
                  .set('status', 'paid')
                  .set('paid_at', DateTime.now().toUtc().toIso8601String()),
            );
      }
      return Response.json(body: result);
    } finally {
      client.close();
    }
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } catch (e) {
    return Response.json(
      statusCode: 502,
      body: {'message': 'PayPal capture failed.', 'error': e.toString()},
    );
  }
}
