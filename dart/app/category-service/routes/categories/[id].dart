import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:category_service/config/db.dart';
import 'package:category_service/repositories/category_repository.dart';
import 'package:category_service/services/category_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  try {
    final db = await Database.connection;
    final service = CategoryService(CategoryRepository(db), db);
    switch (context.request.method) {
      case HttpMethod.get:
        final category = await service.getById(id);
        return category == null
            ? _notFound()
            : Response.json(body: category.toJson());
      case HttpMethod.put:
        final decoded = jsonDecode(await context.request.body());
        if (decoded is! Map<String, dynamic> ||
            decoded['category_name'] is! String ||
            (decoded['description'] != null &&
                decoded['description'] is! String)) {
          return Response.json(
            statusCode: 400,
            body: {'message': 'Invalid category fields.'},
          );
        }
        final updated = await service.update(
          id,
          decoded['category_name'] as String,
          decoded['description'] as String?,
        );
        return updated == null
            ? _notFound()
            : Response.json(body: updated.toJson());
      case HttpMethod.delete:
        return await service.delete(id)
            ? Response.json(body: {'message': 'Category deleted successfully.'})
            : _notFound();
      default:
        return Response.json(
          statusCode: 405,
          body: {'message': 'Method not allowed.'},
        );
    }
  } on FormatException {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Invalid JSON format.'},
    );
  } on ArgumentError catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'message': e.message.toString()},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Internal Server Error.', 'error': e.toString()},
    );
  }
}

Response _notFound() =>
    Response.json(statusCode: 404, body: {'message': 'Category not found.'});
