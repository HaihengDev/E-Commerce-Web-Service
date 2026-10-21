import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

class TokenClaims {
  const TokenClaims({
    required this.subject,
    required this.role,
    required this.name,
  });
  final String subject;
  final String role;
  final String name;

  static TokenClaims? fromAuthorization(String? authorization) {
    if (authorization == null || !authorization.startsWith('Bearer ')) {
      return null;
    }
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'];
    if (secret == null || secret.length < 32) {
      throw StateError(
        'JWT_SECRET must be configured with at least 32 characters.',
      );
    }
    try {
      final token = JWT.verify(authorization.substring(7), SecretKey(secret));
      final payload = Map<String, dynamic>.from(token.payload as Map);
      final subject = payload['sub'];
      final role = payload['role'];
      final name = payload['name'];
      if (subject is! String || role is! String || name is! String) return null;
      return TokenClaims(subject: subject, role: role, name: name);
    } on JWTException {
      return null;
    }
  }
}
