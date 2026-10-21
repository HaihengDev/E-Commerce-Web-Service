import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:auth_service/config/db.dart';
import 'package:auth_service/repositories/user_repository.dart';
import 'package:auth_service/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'message': 'Method not allowed.'},
    );
  }
  try {
    final body = jsonDecode(await context.request.body());
    if (body is! Map<String, dynamic> ||
        body['email'] is! String ||
        body['password'] is! String) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'email and password are required.'},
      );
    }
    final result = await AuthService(UserRepository(await Database.connection))
        .login(
          email: body['email'] as String,
          password: body['password'] as String,
        );
    return Response.json(body: result);
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } on AuthException catch (error) {
    return Response.json(
      statusCode: error.statusCode,
      body: {'message': error.message},
    );
  } catch (error) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Internal server error.', 'error': error.toString()},
    );
  }
}
