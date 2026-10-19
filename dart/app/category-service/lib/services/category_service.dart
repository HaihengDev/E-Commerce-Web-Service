import 'package:mongo_dart/mongo_dart.dart';
import 'package:category_service/models/category_model.dart';
import 'package:category_service/repositories/category_repository.dart';

class CategoryService {
  final CategoryRepository repository;
  final Db database;
  CategoryService(this.repository, this.database);

  Future<List<Category>> getAll() => repository.findAll();
  Future<Category?> getById(String id) => repository.findById(id);

  Future<Category> add(String name, String? description) async {
    final normalized = name.trim();
    if (normalized.isEmpty) throw ArgumentError('Category name is required.');
    final counters = database.collection('counters');
    final counter = await counters.findAndModify(
      query: {'category_id': 'CAT'},
      update: {
        r'$inc': {'sequence': 1},
      },
      upsert: true,
      returnNew: true,
    );
    final sequence = counter?['sequence'];
    if (sequence is! int) throw StateError('Failed to generate category ID.');
    final category = Category(
      category_id: 'CAT${sequence.toString().padLeft(4, '0')}',
      category_name: normalized,
      description: description?.trim(),
    );
    return repository.create(category);
  }

  Future<Category?> update(String id, String name, String? description) {
    final normalized = name.trim();
    if (normalized.isEmpty) throw ArgumentError('Category name is required.');
    return repository.update(
      id,
      Category(
        category_id: id,
        category_name: normalized,
        description: description?.trim(),
      ),
    );
  }

  Future<bool> delete(String id) => repository.delete(id);
}
