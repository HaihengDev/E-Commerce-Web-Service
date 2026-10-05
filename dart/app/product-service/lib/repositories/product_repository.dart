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

  Future<Product> create(Product product) async {
    final collection = await _collection;

    final document = {
      'product_id': product.product_id,
      'product_name': product.product_name,
      'product_imgUrl': product.product_imgUrl,
      'stock': product.stock,
      'discount': product.discount,
      'price': product.price,
    };

    await collection.insertOne(document);

    return Product(
      product_id: product.product_id,
      product_name: product.product_name,
      product_imgUrl: product.product_imgUrl,
      stock: product.stock,
      discount: product.discount,
      price: product.price,
    );
  }

  Future<Product?> update(String id, Product newProduct) async {
    final collection = await _collection;

    final objectId = ObjectId.fromHexString(id);

    final result = await collection.findAndModify(
      query: where.eq('_id', objectId),
      update: modify
          .set('product_id', newProduct.product_id)
          .set('product_name', newProduct.product_name)
          .set('product_imgUrl', newProduct.product_imgUrl)
          .set('stock', newProduct.stock)
          .set('discount', newProduct.discount)
          .set('price', newProduct.price),
      returnNew: true,
    );

    if (result == null) {
      return null;
    }

    return _fromDocument(result);
  }

  Future<Product?> delete(String id) async {
    final collection = await _collection;

    final objectId = ObjectId.fromHexString(id);

    final document = await collection.findAndModify(
      query: where.eq('_id', objectId),
      remove: true,
    );

    if (document == null) {
      return null;
    }

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
