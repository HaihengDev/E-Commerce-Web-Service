import 'dart:math';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:app/config/cache.dart';

class InventoryService {
  InventoryService(this.db);

  final Db db;
  DbCollection get _products => db.collection('products');
  DbCollection get _reservations => db.collection('inventory_reservations');
  DbCollection get _issues => db.collection('license_issues');

  Future<InventoryReservationResult> reserve({
    required String orderId,
    required String userId,
    required List<Map<String, dynamic>> items,
  }) async {
    final existing = await _reservations.findOne(where.eq('_id', orderId));
    if (existing != null) {
      if (existing['user_id'] == userId && existing['status'] == 'reserved') {
        return const InventoryReservationResult.reserved();
      }
      return const InventoryReservationResult.conflict();
    }

    await _reservations.insertOne({
      '_id': orderId,
      'order_id': orderId,
      'user_id': userId,
      'items': items,
      'status': 'reserving',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    final reservedItems = <Map<String, dynamic>>[];
    try {
      for (final item in items) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        final result = await _products.updateOne(
          where.eq('product_id', productId).gte('stock', quantity),
          modify.inc('stock', -quantity),
        );
        if (result.nMatched == 0) {
          await _restore(reservedItems);
          await _reservations.updateOne(
            where.eq('_id', orderId),
            modify.set('status', 'failed'),
          );
          return InventoryReservationResult.outOfStock(productId);
        }
        reservedItems.add(item);
        await _invalidate(productId);
      }
    } catch (_) {
      await _restore(reservedItems);
      await _reservations.updateOne(
        where.eq('_id', orderId),
        modify.set('status', 'failed'),
      );
      rethrow;
    }

    await _reservations.updateOne(
      where.eq('_id', orderId),
      modify.set('status', 'reserved'),
    );
    return const InventoryReservationResult.reserved();
  }

  Future<bool> release(String orderId, String userId) async {
    final reservation = await _reservations.findOne(
      where.eq('_id', orderId).eq('user_id', userId),
    );
    if (reservation == null || reservation['status'] == 'released') {
      return false;
    }
    if (reservation['status'] != 'reserved') return false;

    final claim = await _reservations.updateOne(
      where.eq('_id', orderId).eq('status', 'reserved'),
      modify.set('status', 'releasing'),
    );
    if (claim.nMatched == 0) return false;

    for (final item in reservation['items'] as List) {
      final line = Map<String, dynamic>.from(item as Map);
      await _products.updateOne(
        where.eq('product_id', line['product_id']),
        modify.inc('stock', line['quantity'] as int),
      );
      await _invalidate(line['product_id'] as String);
    }
    await _reservations.updateOne(
      where.eq('_id', orderId),
      modify.set('status', 'released'),
    );
    return true;
  }

  Future<Map<String, dynamic>?> issueFakeSerialCodes({
    required String orderId,
    required String userId,
  }) async {
    final existing = await _issues.findOne(where.eq('_id', orderId));
    if (existing != null) {
      if (existing['user_id'] != userId) return null;
      return Map<String, dynamic>.from(existing);
    }

    final reservation = await _reservations.findOne(
      where.eq('_id', orderId).eq('user_id', userId).eq('status', 'reserved'),
    );
    if (reservation == null) return null;

    final random = Random.secure();
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String segment() => List.generate(
      5,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();

    final items = (reservation['items'] as List).map((rawItem) {
      final item = Map<String, dynamic>.from(rawItem as Map);
      final quantity = item['quantity'] as int;
      return {
        'product_id': item['product_id'],
        'quantity': quantity,
        'serial_codes': List.generate(
          quantity,
          (_) => 'DEMO-${segment()}-${segment()}-${segment()}',
        ),
      };
    }).toList();
    final document = {
      '_id': orderId,
      'order_id': orderId,
      'user_id': userId,
      'items': items,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await _issues.insertOne(document);
      return Map<String, dynamic>.from(document);
    } catch (_) {
      final raced = await _issues.findOne(where.eq('_id', orderId));
      if (raced != null && raced['user_id'] == userId) {
        return Map<String, dynamic>.from(raced);
      }
      rethrow;
    }
  }

  Future<void> _invalidate(String productId) async {
    await Future.wait([
      Cache.delete('products:list'),
      Cache.delete('products:id:$productId'),
    ]);
  }

  Future<void> _restore(List<Map<String, dynamic>> items) async {
    for (final item in items) {
      final productId = item['product_id'] as String;
      await _products.updateOne(
        where.eq('product_id', productId),
        modify.inc('stock', item['quantity'] as int),
      );
      await _invalidate(productId);
    }
  }
}

class InventoryReservationResult {
  const InventoryReservationResult._(this.reserved, this.productId);
  const InventoryReservationResult.reserved() : this._(true, null);
  const InventoryReservationResult.conflict() : this._(false, null);
  const InventoryReservationResult.outOfStock(String productId)
    : this._(false, productId);

  final bool reserved;
  final String? productId;
}
