import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:payment_service/config/db.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post)
    return Response(statusCode: 405);
  final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
  final secret = env['STRIPE_WEBHOOK_SECRET'];
  if (secret == null || secret.isEmpty)
    return Response.json(
      statusCode: 503,
      body: {'message': 'Stripe webhook is not configured.'},
    );
  final rawBody = await context.request.body();
  final signatureHeader = context.request.headers['stripe-signature'];
  if (signatureHeader == null ||
      !_validSignature(rawBody, signatureHeader, secret)) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Invalid Stripe signature.'},
    );
  }
  try {
    final event = jsonDecode(rawBody) as Map<String, dynamic>;
    if (event['type'] == 'checkout.session.completed') {
      final session = event['data']['object'] as Map;
      final orderId =
          (session['metadata'] as Map?)?['order_id'] ??
          session['client_reference_id'];
      if (orderId is String && session['payment_status'] == 'paid') {
        final db = await Database.connection;
        await db
            .collection('payments')
            .updateOne(
              where.eq('session_id', session['id']),
              modify
                  .set('status', 'paid')
                  .set('paid_at', DateTime.now().toUtc().toIso8601String()),
            );
        await db
            .collection('orders')
            .updateOne(
              where.eq('order_id', orderId),
              modify
                  .set('status', 'paid')
                  .set('paid_at', DateTime.now().toUtc().toIso8601String()),
            );
      }
    }
    return Response.json(body: {'received': true});
  } on FormatException {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Invalid webhook JSON.'},
    );
  } catch (_) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Could not process webhook.'},
    );
  }
}

bool _validSignature(String body, String header, String secret) {
  final parts = <String, List<String>>{};
  for (final part in header.split(',')) {
    final pair = part.split('=');
    if (pair.length == 2) (parts[pair[0]] ??= []).add(pair[1]);
  }
  final timestamp = int.tryParse(parts['t']?.first ?? '');
  if (timestamp == null ||
      (DateTime.now().millisecondsSinceEpoch ~/ 1000 - timestamp).abs() > 300)
    return false;
  final signedPayload = '$timestamp.$body';
  final expected = Hmac(
    sha256,
    utf8.encode(secret),
  ).convert(utf8.encode(signedPayload)).toString();
  return (parts['v1'] ?? []).any(
    (candidate) => _constantTimeEquals(candidate, expected),
  );
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return difference == 0;
}
