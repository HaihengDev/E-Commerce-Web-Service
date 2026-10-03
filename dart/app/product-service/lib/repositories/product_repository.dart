import 'package:mongo_dart/mongo_dart.dart';

import '../config/db.dart';
import '../models/product.dart';

class ProductRepository {
  Future<DbCollection> get _collection async {
    final db = await Database.connect();

    return db.collection('products');
  }

  Future<List<Product>> findAll() async {
    final collection = await _collection;

    final documents = await collection.find().toList();

    return documents.map((document) {
      return _fromDocument(document);
    }).toList();
  }

  Future<Product?> findById(String id) async {
    final collection = await _collection;

    final document = await collection.findOne(where.eq('product_id', id));

    if (document == null) return null;

    return _fromDocument(document);
  }

  Product _fromDocument(Map<String, dynamic> document) {
    return Product(
      product_id: document['product_id'] as String,
      product_name: document['product_name'] as String,
      product_imgUrl: document['product_imgUrl'] as String,
      stock: document['stock'] as int,
      discount: document['discount'] as int,
      price: document['price'] as double,
    );
  }
}
