import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:category_service/config/db.dart';
import 'package:category_service/repositories/category_repository.dart';
import 'package:category_service/services/category_service.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final db = await Database.connection;
    final service = CategoryService(CategoryRepository(db), db);
    switch (context.request.method) {
      case HttpMethod.get:
        final categories = await service.getAll();
        return Response.json(body: categories.map((c) => c.toJson()).toList());
      case HttpMethod.post:
        final body = jsonDecode(await context.request.body());
        if (body is! Map<String, dynamic> ||
            body['category_name'] is! String ||
            (body['description'] != null && body['description'] is! String)) {
          return _badRequest(
            'category_name must be a string; description must be a string.',
          );
        }
        final category = await service.add(
          body['category_name'] as String,
          body['description'] as String?,
        );
        return Response.json(statusCode: 201, body: category.toJson());
      default:
        return Response.json(
          statusCode: 405,
          body: {'message': 'Method not allowed.'},
        );
    }
  } on FormatException {
    return _badRequest('Invalid JSON format.');
  } on ArgumentError catch (e) {
    return _badRequest(e.message.toString());
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Internal Server Error.', 'error': e.toString()},
    );
  }
}

Response _badRequest(String message) =>
    Response.json(statusCode: 400, body: {'message': message});
