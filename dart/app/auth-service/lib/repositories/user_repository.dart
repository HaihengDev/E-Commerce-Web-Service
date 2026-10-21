import 'package:mongo_dart/mongo_dart.dart';
import 'package:auth_service/models/user.dart';

class UserRepository {
  UserRepository(this.db);
  final Db db;
  DbCollection get _users => db.collection('users');

  Future<void> ensureIndexes() async {
    await _users.createIndex(
      keys: {'email': 1},
      unique: true,
      name: 'email_unique',
    );
  }

  Future<Map<String, dynamic>?> findByEmail(String email) =>
      _users.findOne(where.eq('email', email));

  Future<AppUser> create({
    required String email,
    required String name,
    required String role,
    required String passwordHash,
  }) async {
    final document = {
      'user_id': ObjectId().oid,
      'email': email,
      'name': name,
      'role': role,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _users.insertOne(document);
    return AppUser.fromDocument(document);
  }
}
