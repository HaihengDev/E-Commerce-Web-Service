import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

class TokenClaims {
  const TokenClaims({required this.subject, required this.role});
  final String subject;
  final String role;

  static TokenClaims? fromAuthorization(String? authorization) {
    if (authorization == null || !authorization.startsWith('Bearer '))
      return null;
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'];
    if (secret == null || secret.length < 32) {
      throw StateError(
        'JWT_SECRET must be configured with at least 32 characters.',
      );
    }
    try {
      final jwt = JWT.verify(authorization.substring(7), SecretKey(secret));
      final payload = Map<String, dynamic>.from(jwt.payload as Map);
      final subject = payload['sub'];
      final role = payload['role'];
      if (subject is! String || role is! String) return null;
      return TokenClaims(subject: subject, role: role);
    } on JWTException {
      return null;
    }
  }
}
