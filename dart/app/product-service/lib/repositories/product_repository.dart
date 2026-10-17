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
}
