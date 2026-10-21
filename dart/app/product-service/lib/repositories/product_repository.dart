import 'package:mongo_dart/mongo_dart.dart';
import 'package:app/models/product_model.dart';
import 'package:app/config/cache.dart';

class ProductRepository {
  final Db db;
  ProductRepository(this.db);

  DbCollection get _collection => db.collection('products');

  Future<List<Product>> findAll() async {
    final cached = await Cache.get<List<Product>>(
      'products:list',
      (value) => (value as List)
          .map(
            (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    if (cached != null) return cached;
    final documents = await _collection.find().toList();
    final products = documents.map(Product.fromJson).toList();
    await Cache.set('products:list', products.map((p) => p.toJson()).toList());
    return products;
  }

  Future<Product?> findById(String id) async {
    final cached = await Cache.get<Product>(
      'products:id:$id',
      (value) => Product.fromJson(Map<String, dynamic>.from(value as Map)),
    );
    if (cached != null) return cached;
    final document = await _collection.findOne(where.eq('product_id', id));

    if (document == null) return null;

    final product = Product.fromJson(document);
    await Cache.set('products:id:$id', product.toJson());
    return product;
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
      'merchant_name': product.merchant_name,
      'merchant_id': product.merchant_id,
    };

    await _collection.insertOne(document);
    await _invalidate(product.product_id);

    return Product.fromJson(document);
  }

  Future<Product?> update(String id, Product newProduct) async {
    final result = await _collection.updateOne(
      where.eq('product_id', id),
      modify
          .set('product_name', newProduct.product_name)
          .set('imgUrl', newProduct.imgUrl)
          .set('stock', newProduct.stock)
          .set('discount', newProduct.discount)
          .set('price', newProduct.price)
          .set('description', newProduct.description)
          .set('category', newProduct.category)
          .set('merchant_name', newProduct.merchant_name),
    );

    if (result.nMatched == 0) {
      return null;
    }
    await _invalidate(id);
    return findById(id);
  }

  Future<bool> delete(String id) async {
    final result = await _collection.deleteOne(where.eq('product_id', id));
    if (result.nRemoved > 0) await _invalidate(id);
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

    if (updates.containsKey('merchant_name')) {
      modifier.set('merchant_name', updates['merchant_name']);
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
    await _invalidate(id);
    return findById(id);
  }

  Future<void> _invalidate(String id) async {
    await Future.wait([
      Cache.delete('products:list'),
      Cache.delete('products:id:$id'),
    ]);
  }
}
