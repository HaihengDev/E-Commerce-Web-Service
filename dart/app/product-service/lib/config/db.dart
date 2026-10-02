import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Database {
  static Db? _db;

  static Future<Db> get connect async {
    if (_db != null && _db!.isConnected) {
      return _db!;
    }

    final env = DotEnv()..load();

    final uri = env['MONGO_URI'];
    final databaseName = env['DATABASE_NAME'];

    if (uri == null || databaseName == null) {
      throw Exception('MongoDB environment variables are missing.');
    }

    _db = await Db.create('$uri/$databaseName');

    await _db!.open();

    print('MongoDB connected.');

    return _db!;
  }
}
