import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:mongo_dart/mongo_dart.dart';

class Database {
  static Db? _db;

  static Future<Db> get connection async {
    if (_db != null && _db!.isConnected) return _db!;
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final uri = env['MONGO_URI_ORDER_SERVICE'];
    if (uri == null || uri.isEmpty) {
      throw StateError('MONGO_URI_ORDER_SERVICE is not configured.');
    }
    _db = await Db.create(uri);
    await _db!.open();
    return _db!;
  }
}
