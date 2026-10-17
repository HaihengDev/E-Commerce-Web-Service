import 'package:mongo_dart/mongo_dart.dart';
import './generate_id.dart';

class IdGenerator {
  final Db database;

  IdGenerator(this.database);

  Future<String> nextId(String prefix) async {
    final counters = database.collection('counters');

    final result = await counters.findAndModify(
      query: {'product_id': prefix},
      update: {
        r'$inc': {'sequence': 1},
      },
      upsert: true,
      returnNew: true,
    );

    if (result == null || result['sequence'] == null) {
      throw Exception('Failed to generate ID for $prefix');
    }

    return generateId(prefix, result['sequence'] as int);
  }
}
