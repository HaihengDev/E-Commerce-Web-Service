import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:payment_service/config/db.dart';
import 'package:payment_service/security/token_claims.dart';
import 'package:payment_service/services/order_fulfillment_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'message': 'Method not allowed.'},
    );
  }

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
      body: {'message': 'Only users can complete demo payments.'},
    );
  }

  try {
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    if (env['PAYMENT_DEMO_MODE'] != 'true') {
      return Response.json(
        statusCode: 403,
        body: {'message': 'Local demo payments are disabled.'},
      );
    }
    final body = jsonDecode(await context.request.body());
    if (body is! Map<String, dynamic> || body['payment_id'] is! String) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'payment_id is required.'},
      );
    }

    final db = await Database.connection;
    final payments = db.collection('payments');
    final payment = await payments.findOne(
      where
          .eq('payment_id', body['payment_id'])
          .eq('provider', 'demo')
          .eq('user_id', claims.subject),
    );
    if (payment == null) {
      return Response.json(
        statusCode: 404,
        body: {'message': 'Demo payment not found.'},
      );
    }
    if (payment['status'] != 'pending' && payment['status'] != 'paid') {
      return Response.json(
        statusCode: 409,
        body: {'message': 'Demo payment is not pending.'},
      );
    }

    final client = http.Client();
    try {
      final order = await OrderFulfillmentService(db, client).fulfillPaidOrder(
        payment['order_id'] as String,
        expectedUserId: claims.subject,
      );
      await payments.updateOne(
        where.eq('payment_id', payment['payment_id']),
        modify.set('status', 'paid'),
      );
      return Response.json(
        body: {
          'payment_id': payment['payment_id'],
          'order_id': payment['order_id'],
          'status': 'paid',
          'demo': true,
          'items': order['items'],
        },
      );
    } finally {
      client.close();
    }
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } catch (_) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Could not complete demo payment.'},
    );
  }
}
