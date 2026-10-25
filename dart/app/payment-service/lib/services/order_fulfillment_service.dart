import 'dart:convert';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';

class OrderFulfillmentService {
  OrderFulfillmentService(this.db, this.client);

  final Db db;
  final http.Client client;

  Future<Map<String, dynamic>> fulfillPaidOrder(
    String orderId, {
    String? expectedUserId,
  }) async {
    final orders = db.collection('orders');
    final order = await orders.findOne(where.eq('order_id', orderId));
    if (order == null ||
        (expectedUserId != null && order['user_id'] != expectedUserId)) {
      throw StateError('Paid order was not found for this customer.');
    }
    final userId = order['user_id'] as String;
    final currentItems = (order['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    if (order['status'] == 'paid' &&
        currentItems.every((item) => item['serial_codes'] is List)) {
      return Map<String, dynamic>.from(order);
    }

    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final token = env['INTERNAL_SERVICE_TOKEN'];
    if (token == null || token.length < 32) {
      throw StateError('INTERNAL_SERVICE_TOKEN is not configured.');
    }
    final productServiceUrl =
        env['PRODUCT_SERVICE_URL'] ?? 'http://localhost:8086';
    final response = await client
        .post(
          Uri.parse(productServiceUrl).resolve('/internal/inventory/fulfill'),
          headers: {
            'Content-Type': 'application/json',
            'x-internal-service-token': token,
          },
          body: jsonEncode({'order_id': orderId, 'user_id': userId}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('Product service could not issue serial codes.');
    }
    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic> || payload['items'] is! List) {
      throw StateError('Product service returned invalid serial codes.');
    }
    final issuedItems = (payload['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    if (issuedItems.length != currentItems.length) {
      throw StateError('Product service returned an incomplete fulfillment.');
    }

    final fulfilledItems = <Map<String, dynamic>>[];
    for (var i = 0; i < currentItems.length; i++) {
      final item = currentItems[i];
      final issued = issuedItems[i];
      if (item['product_id'] != issued['product_id'] ||
          issued['serial_codes'] is! List ||
          (issued['serial_codes'] as List).length != item['quantity']) {
        throw StateError('Product service returned invalid serial codes.');
      }
      fulfilledItems.add({...item, 'serial_codes': issued['serial_codes']});
    }

    final paidAt = DateTime.now().toUtc().toIso8601String();
    final update = await orders.updateOne(
      where.eq('order_id', orderId).eq('user_id', userId),
      modify
          .set('items', fulfilledItems)
          .set('status', 'paid')
          .set('paid_at', paidAt)
          .set('fulfilled_at', paidAt),
    );
    if (update.nMatched == 0) {
      throw StateError('Order could not be marked as fulfilled.');
    }
    await db
        .collection('payments')
        .updateOne(
          where.eq('order_id', orderId).eq('user_id', userId),
          modify.set('status', 'paid').set('paid_at', paidAt),
        );
    return {
      ...Map<String, dynamic>.from(order),
      'items': fulfilledItems,
      'status': 'paid',
      'paid_at': paidAt,
      'fulfilled_at': paidAt,
    };
  }
}
