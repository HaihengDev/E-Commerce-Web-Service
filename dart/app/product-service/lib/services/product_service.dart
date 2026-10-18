import 'package:mongo_dart/mongo_dart.dart';
import '../models/product_model.dart';
import '../repositories//product_repository.dart';
import '../utils/IdGenerator.dart';
import '../utils/data_validation.dart';

class ProductService {
  final ProductRepository repository;
  final Db database;
  late final IdGenerator _idGenerator;

  ProductService(this.repository, this.database) {
    _idGenerator = IdGenerator(database);
  }

  Future<List<Product>> getAll() async {
    return repository.findAll();
  }

  Future<Product?> getById(String id) async {
    return repository.findById(id);
  }

  Future<Product?> add(Product product) async {
    final product_id = await _idGenerator.nextId('PRD');

    dataValidation(product);

    final data = Product(
      product_id: product_id,
      product_name: product.product_name,
      imgUrl: product.imgUrl,
      stock: product.stock,
      discount: product.discount,
      price: product.price,
      description: product.description,
      category: product.category,
    );

    return repository.create(data);
  }

  Future<Product?> update(String product_id, Product newProduct) async {
    dataValidation(newProduct);

    return repository.update(product_id, newProduct);
  }

  Future<bool?> delete(String product_id) async {
    return repository.delete(product_id);
  }

  Future<Product?> patch(String product_id, Product newProduct) async {
    dataValidation(newProduct);

    final updates = <String, dynamic>{};

    if (newProduct.product_name != null) {
      updates['product_name'] = newProduct.product_name.trim();
    }

    if (newProduct.imgUrl != null) {
      updates['imgUrl'] = newProduct.imgUrl;
    }

    if (newProduct.stock != null) {
      updates['stock'] = newProduct.stock;
    }

    if (newProduct.discount != null) {
      updates['discount'] = newProduct.discount;
    }

    if (newProduct.price != null) {
      updates['price'] = newProduct.price;
    }

    if (newProduct.description != null) {
      updates['description'] = newProduct.description.trim();
    }

    if (newProduct.category != null) {
      updates['category'] = newProduct.category;
    }

    if (updates.isEmpty) {
      throw ArgumentError('No field provided to updates.');
    }

    return await repository.patch(product_id, updates);
  }
}
