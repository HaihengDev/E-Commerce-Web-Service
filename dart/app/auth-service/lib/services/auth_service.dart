import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:auth_service/models/user.dart';
import 'package:auth_service/repositories/user_repository.dart';
import 'package:auth_service/services/token_service.dart';

class AuthException implements Exception {
  const AuthException(this.statusCode, this.message);
  final int statusCode;
  final String message;
}

class AuthService {
  AuthService(this.repository);
  final UserRepository repository;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();
    if (!_validEmail(normalizedEmail)) {
      throw const AuthException(400, 'A valid email is required.');
    }
    if (password.length < 8 || utf8.encode(password).length > 72) {
      throw const AuthException(400, 'Password must be 8 to 72 characters.');
    }
    if (normalizedName.length < 2 || normalizedName.length > 80) {
      throw const AuthException(400, 'Name must be 2 to 80 characters.');
    }
    if (role != 'user' && role != 'merchant') {
      throw const AuthException(400, 'Role must be user or merchant.');
    }
    if (await repository.findByEmail(normalizedEmail) != null) {
      throw const AuthException(
        409,
        'An account with this email already exists.',
      );
    }

    try {
      final user = await repository.create(
        email: normalizedEmail,
        name: normalizedName,
        role: role,
        passwordHash: BCrypt.hashpw(password, BCrypt.gensalt()),
      );
      return _session(user);
    } on MongoDartError catch (error) {
      if (error.message.toLowerCase().contains('duplicate')) {
        throw const AuthException(
          409,
          'An account with this email already exists.',
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final document = await repository.findByEmail(email.trim().toLowerCase());
    if (document == null ||
        !BCrypt.checkpw(password, document['password_hash'] as String)) {
      throw const AuthException(401, 'Invalid email or password.');
    }
    return _session(AppUser.fromDocument(document));
  }

  Map<String, dynamic> _session(AppUser user) => {
    'access_token': TokenService.issue(user),
    'token_type': 'Bearer',
    'expires_in': 3600,
    'user': user.toPublicJson(),
  };

  bool _validEmail(String email) =>
      email.length <= 254 &&
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
}
