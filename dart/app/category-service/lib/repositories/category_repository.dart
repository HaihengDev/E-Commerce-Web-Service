import 'package:mongo_dart/mongo_dart.dart';
import 'package:category_service/models/category_model.dart';

class CategoryRepository {
  final Db db;
  CategoryRepository(this.db);

  DbCollection get _collection => db.collection('categories');

  Future<List<Category>> findAll() async =>
      (await _collection.find().toList()).map(Category.fromJson).toList();

  Future<Category?> findById(String id) async {
    final doc = await _collection.findOne(where.eq('category_id', id));
    return doc == null ? null : Category.fromJson(doc);
  }

  Future<Category> create(Category category) async {
    final doc = category.toJson();
    await _collection.insertOne(doc);
    return Category.fromJson(doc);
  }

  Future<Category?> update(String id, Category category) async {
    final result = await _collection.updateOne(
      where.eq('category_id', id),
      modify
          .set('category_name', category.category_name)
          .set('description', category.description),
    );
    return result.nMatched == 0 ? null : findById(id);
  }

  Future<bool> delete(String id) async =>
      (await _collection.deleteOne(where.eq('category_id', id))).nRemoved > 0;
}
