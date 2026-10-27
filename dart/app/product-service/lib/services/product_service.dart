import 'package:mongo_dart/mongo_dart.dart';
import 'package:app/models/product_model.dart';
import 'package:app/config/db.dart';
import 'package:app/repositories/product_repository.dart';
import 'package:app/utils/IdGenerator.dart';
import 'package:app/utils/data_validation.dart';
import 'package:app/services/category_client.dart';

class ProductService {
  final ProductRepository repository;
  final Db database;
  late final IdGenerator _idGenerator;
  final CategoryClient _categoryClient = CategoryClient();

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
    _requireMerchantName(product.merchant_name);
    await _categoryClient.requireCategory(product.category);

    final data = Product(
      product_id: product_id,
      product_name: product.product_name,
      imgUrl: product.imgUrl,
      stock: product.stock,
      discount: product.discount,
      price: product.price,
      description: product.description,
      category: product.category,
      merchant_name: product.merchant_name!.trim(),
      merchant_id: product.merchant_id,
    );

    return repository.create(data);
  }

  Future<Product?> update(String product_id, Product newProduct) async {
    dataValidation(newProduct);
    _requireMerchantName(newProduct.merchant_name);
    await _categoryClient.requireCategory(newProduct.category);

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
      await _categoryClient.requireCategory(newProduct.category);
      updates['category'] = newProduct.category;
    }

    if (newProduct.merchant_name != null) {
      updates['merchant_name'] = _requireMerchantName(newProduct.merchant_name);
    }

    if (updates.isEmpty) {
      throw ArgumentError('No field provided to updates.');
    }

    return await repository.patch(product_id, updates);
  }

  String _requireMerchantName(String? name) {
    final normalized = name?.trim();
    if (normalized == null || normalized.isEmpty) {
      throw ArgumentError('Merchant name is required.');
    }
    return normalized;
  }
}
