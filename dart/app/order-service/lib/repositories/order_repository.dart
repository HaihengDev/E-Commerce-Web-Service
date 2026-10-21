import 'package:mongo_dart/mongo_dart.dart';

class OrderRepository {
  OrderRepository(this.db);
  final Db db;
  DbCollection get _orders => db.collection('orders');

  Future<Map<String, dynamic>> create(
    String userId,
    List<Map<String, dynamic>> items,
  ) async {
    final document = {
      'order_id': ObjectId().oid,
      'user_id': userId,
      'items': items,
      'status': 'pending',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _orders.insertOne(document);
    return Map<String, dynamic>.fromEntries(
      document.entries.where((entry) => entry.key != '_id'),
    );
  }

  Future<List<Map<String, dynamic>>> findByUser(String userId) async =>
      (await _orders.find(where.eq('user_id', userId)).toList())
          .map(
            (order) => Map<String, dynamic>.fromEntries(
              order.entries.where((entry) => entry.key != '_id'),
            ),
          )
          .toList();
}
