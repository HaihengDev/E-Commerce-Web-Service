import 'dart:convert';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';

class CheckoutService {
  CheckoutService(this.db, this.client);
  final Db db;
  final http.Client client;

  Future<Map<String, dynamic>> getOrderTotal(
    String orderId,
    String userId,
  ) async {
    final order = await db
        .collection('orders')
        .findOne(where.eq('order_id', orderId).eq('user_id', userId));
    if (order == null) throw CheckoutException(404, 'Order not found.');
    if (order['status'] == 'paid')
      throw CheckoutException(409, 'Order is already paid.');
    final items = order['items'];
    if (items is! List || items.isEmpty)
      throw CheckoutException(400, 'Order has no items.');

    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final productsUrl = Uri.parse(
      env['PRODUCT_SERVICE_URL'] ?? 'http://localhost:8001',
    );
    var totalCents = 0;
    final lineItems = <Map<String, dynamic>>[];
    for (final item in items) {
      if (item is! Map ||
          item['product_id'] is! String ||
          item['quantity'] is! int) {
        throw CheckoutException(400, 'Order contains invalid items.');
      }
      final response = await client.get(
        productsUrl.resolve(
          '/${Uri.encodeComponent(item['product_id'] as String)}',
        ),
      );
      if (response.statusCode != 200)
        throw CheckoutException(400, 'A product in this order is unavailable.');
      final product = jsonDecode(response.body);
      if (product is! Map || product['price'] is! num)
        throw CheckoutException(
          502,
          'Product service returned invalid pricing.',
        );
      final price = (product['price'] as num).toDouble();
      final discount = product['discount'] is num
          ? (product['discount'] as num).toDouble()
          : 0.0;
      if (price <= 0 || discount < 0 || discount > 100)
        throw CheckoutException(400, 'Product has invalid pricing.');
      final unitCents = ((price * (1 - discount / 100)) * 100).round();
      final quantity = item['quantity'] as int;
      totalCents += unitCents * quantity;
      lineItems.add({
        'product_id': item['product_id'],
        'name': product['product_name'] ?? item['product_id'],
        'quantity': quantity,
        'unit_amount': unitCents,
      });
    }
    if (totalCents < 1)
      throw CheckoutException(400, 'Order total must be greater than zero.');
    return {'order': order, 'items': lineItems, 'total_cents': totalCents};
  }
}

class CheckoutException implements Exception {
  CheckoutException(this.statusCode, this.message);
  final int statusCode;
  final String message;
}
