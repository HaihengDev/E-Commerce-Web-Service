import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:auth_service/config/db.dart';
import 'package:auth_service/repositories/user_repository.dart';
import 'package:auth_service/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) return _methodNotAllowed();
  try {
    final body = jsonDecode(await context.request.body());
    if (body is! Map<String, dynamic> ||
        body['email'] is! String ||
        body['password'] is! String ||
        body['name'] is! String ||
        (body['role'] != null && body['role'] is! String)) {
      return Response.json(
        statusCode: 400,
        body: {
          'message':
              'email, password, and name are required; role is optional.',
        },
      );
    }
    final db = await Database.connection;
    final repository = UserRepository(db);
    await repository.ensureIndexes();
    final result = await AuthService(repository).register(
      email: body['email'] as String,
      password: body['password'] as String,
      name: body['name'] as String,
      role: body['role'] as String? ?? 'user',
    );
    return Response.json(statusCode: 201, body: result);
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } on AuthException catch (error) {
    return Response.json(
      statusCode: error.statusCode,
      body: {'message': error.message},
    );
  } catch (error, stackTrace) {
    print('Registration failed: $error\n$stackTrace');
    return Response.json(
      statusCode: 500,
      body: {'message': 'Internal server error.', 'error': error.toString()},
    );
  }
}

Response _methodNotAllowed() =>
    Response.json(statusCode: 405, body: {'message': 'Method not allowed.'});
