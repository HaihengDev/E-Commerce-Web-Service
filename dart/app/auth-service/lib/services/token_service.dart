import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:auth_service/models/user.dart';

class TokenService {
  static String _secret() {
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'];
    if (secret == null || secret.length < 32) {
      throw StateError(
        'JWT_SECRET must be configured with at least 32 characters.',
      );
    }
    return secret;
  }

  static String issue(AppUser user) {
    final jwt = JWT({
      'sub': user.id,
      'email': user.email,
      'name': user.name,
      'role': user.role,
    }, issuer: 'ecommerce-auth-service');
    return jwt.sign(SecretKey(_secret()), expiresIn: const Duration(hours: 1));
  }
}
