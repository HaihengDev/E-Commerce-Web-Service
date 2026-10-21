import 'package:mongo_dart/mongo_dart.dart';
import 'package:category_service/models/category_model.dart';
import 'package:category_service/config/cache.dart';

class CategoryRepository {
  final Db db;
  CategoryRepository(this.db);

  DbCollection get _collection => db.collection('categories');

  Future<List<Category>> findAll() async {
    final cached = await Cache.get<List<Category>>(
      'categories:list',
      (value) => (value as List)
          .map(
            (item) => Category.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    if (cached != null) return cached;
    final categories = (await _collection.find().toList())
        .map(Category.fromJson)
        .toList();
    await Cache.set(
      'categories:list',
      categories.map((c) => c.toJson()).toList(),
    );
    return categories;
  }

  Future<Category?> findById(String id) async {
    final cached = await Cache.get<Category>(
      'categories:id:$id',
      (value) => Category.fromJson(Map<String, dynamic>.from(value as Map)),
    );
    if (cached != null) return cached;
    final doc = await _collection.findOne(where.eq('category_id', id));
    if (doc == null) return null;
    final category = Category.fromJson(doc);
    await Cache.set('categories:id:$id', category.toJson());
    return category;
  }

  Future<Category> create(Category category) async {
    final doc = category.toJson();
    await _collection.insertOne(doc);
    await _invalidate(category.category_id);
    return Category.fromJson(doc);
  }

  Future<Category?> update(String id, Category category) async {
    final result = await _collection.updateOne(
      where.eq('category_id', id),
      modify
          .set('category_name', category.category_name)
          .set('description', category.description),
    );
    if (result.nMatched == 0) return null;
    await _invalidate(id);
    return findById(id);
  }

  Future<bool> delete(String id) async {
    final deleted =
        (await _collection.deleteOne(where.eq('category_id', id))).nRemoved > 0;
    if (deleted) await _invalidate(id);
    return deleted;
  }

  Future<void> _invalidate(String id) async {
    await Future.wait([
      Cache.delete('categories:list'),
      Cache.delete('categories:id:$id'),
    ]);
  }
}
