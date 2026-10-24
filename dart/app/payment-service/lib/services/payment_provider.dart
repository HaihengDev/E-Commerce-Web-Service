import 'dart:convert';
import 'dart:math';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:http/http.dart' as http;

class PaymentProvider {
  PaymentProvider(this.client);
  final http.Client client;

  dotenv.DotEnv _env() =>
      dotenv.DotEnv(includePlatformEnvironment: true)..load();

  Future<Map<String, dynamic>> createStripeSession(
    Map<String, dynamic> checkout,
    String orderId,
    String successUrl,
    String cancelUrl,
  ) async {
    final env = _env();
    final key = env['STRIPE_SECRET_KEY'];
    if (key == null || !key.startsWith('sk_test_'))
      throw StateError('Configure a Stripe test key in STRIPE_SECRET_KEY.');
    final fields = <String, String>{
      'mode': 'payment',
      'success_url': successUrl,
      'cancel_url': cancelUrl,
      'client_reference_id': orderId,
      'metadata[order_id]': orderId,
    };
    final items = checkout['items'] as List<Map<String, dynamic>>;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      fields['line_items[$i][price_data][currency]'] = 'usd';
      fields['line_items[$i][price_data][unit_amount]'] =
          '${item['unit_amount']}';
      fields['line_items[$i][price_data][product_data][name]'] =
          '${item['name']}';
      fields['line_items[$i][quantity]'] = '${item['quantity']}';
    }
    final response = await client.post(
      Uri.https('api.stripe.com', '/v1/checkout/sessions'),
      headers: {'Authorization': 'Bearer $key'},
      body: fields,
    );
    final payload = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = payload is Map ? payload['error'] : null;
      throw StateError(
        'Stripe rejected checkout: ${error is Map ? error['message'] : 'unknown error'}',
      );
    }
    return {
      'provider': 'stripe',
      'session_id': payload['id'],
      'checkout_url': payload['url'],
      'amount_cents': checkout['total_cents'],
      'currency': 'usd',
    };
  }

  Future<Map<String, dynamic>> createPayPalOrder(
    Map<String, dynamic> checkout,
    String orderId,
    String returnUrl,
    String cancelUrl,
  ) async {
    final env = _env();
    final clientId = env['PAYPAL_CLIENT_ID'];
    final secret = env['PAYPAL_CLIENT_SECRET'];
    if (clientId == null || secret == null)
      throw StateError('Configure PAYPAL_CLIENT_ID and PAYPAL_CLIENT_SECRET.');
    final baseUrl =
        env['PAYPAL_BASE_URL'] ?? 'https://api-m.sandbox.paypal.com';
    final auth = await client.post(
      Uri.parse('$baseUrl/v1/oauth2/token'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );
    final authBody = jsonDecode(auth.body);
    if (auth.statusCode != 200)
      throw StateError('PayPal authentication failed.');
    final token = authBody['access_token'] as String;
    final amount = ((checkout['total_cents'] as int) / 100).toStringAsFixed(2);
    final response = await client.post(
      Uri.parse('$baseUrl/v2/checkout/orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'intent': 'CAPTURE',
        'purchase_units': [
          {
            'reference_id': orderId,
            'custom_id': orderId,
            'amount': {'currency_code': 'USD', 'value': amount},
          },
        ],
        'application_context': {
          'return_url': returnUrl,
          'cancel_url': cancelUrl,
        },
      }),
    );
    final payload = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw StateError('PayPal rejected checkout.');
    final approval = (payload['links'] as List).cast<Map>().firstWhere(
      (link) => link['rel'] == 'approve',
    );
    return {
      'provider': 'paypal',
      'paypal_order_id': payload['id'],
      'approval_url': approval['href'],
      'amount_cents': checkout['total_cents'],
      'currency': 'usd',
    };
  }

  Future<Map<String, dynamic>> capturePayPalOrder(String paypalOrderId) async {
    final env = _env();
    final clientId = env['PAYPAL_CLIENT_ID'];
    final secret = env['PAYPAL_CLIENT_SECRET'];
    if (clientId == null || secret == null)
      throw StateError('Configure PAYPAL_CLIENT_ID and PAYPAL_CLIENT_SECRET.');
    final baseUrl =
        env['PAYPAL_BASE_URL'] ?? 'https://api-m.sandbox.paypal.com';
    final auth = await client.post(
      Uri.parse('$baseUrl/v1/oauth2/token'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );
    final token = (jsonDecode(auth.body) as Map)['access_token'] as String;
    final response = await client.post(
      Uri.parse(
        '$baseUrl/v2/checkout/orders/${Uri.encodeComponent(paypalOrderId)}/capture',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{}',
    );
    final payload = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw StateError('PayPal capture failed.');
    final purchase = (payload['purchase_units'] as List).first as Map;
    return {
      'provider': 'paypal',
      'paypal_order_id': payload['id'],
      'order_id': purchase['custom_id'] ?? purchase['reference_id'],
      'status': payload['status'],
      'capture': (purchase['payments'] as Map?)?['captures'],
    };
  }

  String newPaymentId() =>
      'pay_${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(1 << 32).toRadixString(16)}';
}
