import 'package:mongo_dart/mongo_dart.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Db db;
  ProductRepository(this.db);

  DbCollection get _collection => db.collection('products');

  Future<List<Product>> findAll() async {
    final documents = await _collection.find().toList();

    return documents.map(Product.fromJson).toList();
  }

  Future<Product?> findById(String id) async {
    final document = await _collection.findOne(where.eq('product_id', id));

    if (document == null) return null;

    return Product.fromJson(document);
  }

  Future<Product> create(Product product) async {
    final document = {
      'product_id': product.product_id,
      'product_name': product.product_name,
      'imgUrl': product.imgUrl,
      'stock': product.stock,
      'discount': product.discount,
      'price': product.price,
      'description': product.description,
      'category': product.category,
    };

    await _collection.insertOne(document);

    return Product.fromJson(document);
  }

  Future<Product?> update(String id, Product newProduct) async {
    final result = await _collection.updateOne(
      where.eq('product_id', id),
      modify
          .set('name', newProduct.product_name)
          .set('imgUrl', newProduct.imgUrl)
          .set('stock', newProduct.stock)
          .set('discount', newProduct.discount)
          .set('price', newProduct.price)
          .set('description', newProduct.description)
          .set('category', newProduct.category),
    );

    if (result.nMatched == 0) {
      return null;
    }

    return findById(id);
  }

  Future<bool> delete(String id) async {
    final result = await _collection.deleteOne(where.eq('product_id', id));

    return result.nRemoved > 0;
  }

  Future<Product?> patch(String id, Map<String, dynamic> updates) async {
    final modifier = ModifierBuilder();

    if (updates.containsKey('product_id')) {
      modifier.set('product_id', updates['product_id']);
    }

    if (updates.containsKey('product_name')) {
      modifier.set('product_name', updates['product_name']);
    }

    if (updates.containsKey('imgUrl')) {
      modifier.set('imgUrl', updates['imgUrl']);
    }

    if (updates.containsKey('stock')) {
      modifier.set('stock', updates['stock']);
    }

    if (updates.containsKey('discount')) {
      modifier.set('discount', updates['discount']);
    }

    if (updates.containsKey('price')) {
      modifier.set('price', updates['price']);
    }

    if (updates.containsKey('description')) {
      modifier.set('description', updates['description']);
    }

    if (updates.containsKey('category')) {
      modifier.set('category', updates['category']);
    }

    if (updates.isEmpty) {
      return findById(id);
    }

    final result = await _collection.updateOne(
      where.eq('product_id', id),
      modifier,
    );

    if (result.nMatched == 0) {
      return null;
    }

    return findById(id);
  }
}
