import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:payment_service/config/db.dart';
import 'package:payment_service/security/token_claims.dart';
import 'package:payment_service/services/checkout_service.dart';
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
        body: {'message': 'Only users can create payments.'},
      );
    final body = jsonDecode(await context.request.body());
    if (body is! Map<String, dynamic> ||
        body['order_id'] is! String ||
        body['provider'] is! String)
      return _badRequest('order_id and provider are required.');
    final orderId = (body['order_id'] as String).trim();
    if (orderId.isEmpty) return _badRequest('order_id is required.');
    final returnUrl = body['return_url'] as String?;
    final cancelUrl = body['cancel_url'] as String?;
    if (returnUrl == null ||
        cancelUrl == null ||
        Uri.tryParse(returnUrl)?.hasScheme != true ||
        Uri.tryParse(cancelUrl)?.hasScheme != true)
      return _badRequest('return_url and cancel_url must be absolute URLs.');
    final db = await Database.connection;
    final client = http.Client();
    try {
      final checkout = await CheckoutService(
        db,
        client,
      ).getOrderTotal(orderId, claims.subject);
      final provider = PaymentProvider(client);
      final result = switch (body['provider']) {
        'stripe' => await provider.createStripeSession(
          checkout,
          orderId,
          returnUrl,
          cancelUrl,
        ),
        'paypal' => await provider.createPayPalOrder(
          checkout,
          orderId,
          returnUrl,
          cancelUrl,
        ),
        _ => throw CheckoutException(400, 'provider must be stripe or paypal.'),
      };
      await db.collection('payments').insertOne({
        ...result,
        'payment_id': provider.newPaymentId(),
        'user_id': claims.subject,
        'order_id': orderId,
        'status': 'pending',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return Response.json(statusCode: 201, body: result);
    } finally {
      client.close();
    }
  } on CheckoutException catch (e) {
    return Response.json(
      statusCode: e.statusCode,
      body: {'message': e.message},
    );
  } on FormatException {
    return _badRequest('Invalid JSON.');
  } catch (e) {
    return Response.json(
      statusCode: 502,
      body: {
        'message': 'Payment provider request failed.',
        'error': e.toString(),
      },
    );
  }
}

Response _badRequest(String message) =>
    Response.json(statusCode: 400, body: {'message': message});
