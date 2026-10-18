import '../models/product_model.dart';

void dataValidation(Product product) {
  if (product.product_name.trim().isEmpty) {
    throw ArgumentError('Product name is required.');
  }

  if (product.stock! < 0) {
    throw ArgumentError('Product stock cannot be negative.');
  }

  if (product.discount! < 0) {
    throw ArgumentError('Product discount cannot be negative.');
  }

  if (product.price < 0) {
    throw ArgumentError('Product price cannot be negative.');
  }

  if (product.description.trim().isEmpty) {
    throw ArgumentError('Product description is required.');
  }

  if (product.category.trim().isEmpty) {
    throw ArgumentError('Product category is required.');
  }
}
