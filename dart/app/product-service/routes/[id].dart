import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'package:app/config/db.dart';
import 'package:app/models/product_model.dart';
import 'package:app/repositories/product_repository.dart';
import 'package:app/services/product_service.dart';
import 'package:app/security/token_claims.dart';

Future<ProductService> _service() async {
  final db = await Database.connection;
  return ProductService(ProductRepository(db), db);
}

Future<Response> onRequest(RequestContext context, String id) async {
  try {
    final service = await _service();
    switch (context.request.method) {
      case HttpMethod.get:
        return _readById(service, id);
      case HttpMethod.put:
        final claims = _merchantClaims(context);
        if (claims == null) return _unauthorized();
        if (claims.role != 'merchant') return _forbidden();
        if (!await _ownsProduct(service, id, claims.subject)) {
          return _notFound();
        }
        return _update(service, id, context.request);
      case HttpMethod.delete:
        final deleteClaims = _merchantClaims(context);
        if (deleteClaims == null) return _unauthorized();
        if (deleteClaims.role != 'merchant') return _forbidden();
        if (!await _ownsProduct(service, id, deleteClaims.subject)) {
          return _notFound();
        }
        return _delete(service, id);
      case HttpMethod.patch:
        final patchClaims = _merchantClaims(context);
        if (patchClaims == null) return _unauthorized();
        if (patchClaims.role != 'merchant') return _forbidden();
        if (!await _ownsProduct(service, id, patchClaims.subject)) {
          return _notFound();
        }
        return _patch(service, id, context.request);
      default:
        return Response.json(
          statusCode: 405,
          body: {'message': 'Method not allowed.'},
        );
    }
  } catch (e) {
    return _serverError(e);
  }
}

TokenClaims? _merchantClaims(RequestContext context) =>
    TokenClaims.fromAuthorization(context.request.headers['authorization']);

Future<bool> _ownsProduct(
  ProductService service,
  String id,
  String subject,
) async {
  final product = await service.getById(id);
  return product?.merchant_id == subject;
}

Future<Response> _readById(ProductService service, String id) async {
  try {
    final product = await service.getById(id);
    if (product == null) return _notFound();
    return Response.json(body: product.toJson());
  } catch (e) {
    return _serverError(e);
  }
}

Future<Response> _update(
  ProductService service,
  String id,
  Request request,
) async {
  try {
    final json = await _readJson(request);
    final claims = TokenClaims.fromAuthorization(
      request.headers['authorization'],
    );
    if (claims == null) return _unauthorized();
    final product = _productFromJson(json, id, claims.name);
    final updated = await service.update(id, product);
    if (updated == null) return _notFound();
    return Response.json(body: updated.toJson());
  } on FormatException {
    return _badRequest('Invalid JSON format.');
  } on ArgumentError catch (e) {
    return _badRequest(e.message.toString());
  } on TypeError {
    return _badRequest('Missing or invalid product fields.');
  } catch (e) {
    return _serverError(e);
  }
}

Future<Response> _delete(ProductService service, String id) async {
  try {
    final deleted = await service.delete(id);
    if (deleted != true) return _notFound();
    return Response.json(body: {'message': 'Product deleted successfully.'});
  } catch (e) {
    return _serverError(e);
  }
}

Future<Response> _patch(
  ProductService service,
  String id,
  Request request,
) async {
  try {
    final json = await _readJson(request);
    final current = await service.getById(id);
    if (current == null) return _notFound();

    const allowedFields = {
      'product_name',
      'imgUrl',
      'stock',
      'discount',
      'price',
      'description',
      'category',
    };
    if (json.keys.any((key) => !allowedFields.contains(key))) {
      return _badRequest('Request contains an unsupported product field.');
    }

    final product = Product(
      product_id: id,
      product_name: json['product_name'] as String? ?? current.product_name,
      imgUrl: json['imgUrl'] as String? ?? current.imgUrl,
      stock: json['stock'] as int? ?? current.stock,
      discount: json['discount'] as int? ?? current.discount,
      price: (json['price'] as num?)?.toDouble() ?? current.price,
      description: json['description'] as String? ?? current.description,
      category: json['category'] as String? ?? current.category,
      merchant_name: current.merchant_name,
      merchant_id: current.merchant_id,
    );

    final updated = await service.patch(id, product);
    if (updated == null) return _notFound();
    return Response.json(body: updated.toJson());
  } on FormatException {
    return _badRequest('Invalid JSON format.');
  } on ArgumentError catch (e) {
    return _badRequest(e.message.toString());
  } on TypeError {
    return _badRequest('One or more product fields have an invalid type.');
  } catch (e) {
    return _serverError(e);
  }
}

Future<Map<String, dynamic>> _readJson(Request request) async {
  final decoded = jsonDecode(await request.body());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Request body must be a JSON object.');
  }
  return decoded;
}

Product _productFromJson(
  Map<String, dynamic> json,
  String id,
  String merchantName,
) {
  return Product(
    product_id: id,
    product_name: json['product_name'] as String,
    imgUrl: json['imgUrl'] as String?,
    stock: json['stock'] as int,
    discount: json['discount'] as int,
    price: (json['price'] as num).toDouble(),
    description: json['description'] as String,
    category: json['category'] as String,
    merchant_name: merchantName,
  );
}

Response _badRequest(String message) =>
    Response.json(statusCode: 400, body: {'message': message});

Response _notFound() =>
    Response.json(statusCode: 404, body: {'message': 'Product not found.'});

Response _serverError(Object error) => Response.json(
  statusCode: 500,
  body: {'message': 'Internal Server Error.', 'error': error.toString()},
);

Response _unauthorized() => Response.json(
  statusCode: 401,
  body: {'message': 'A valid bearer token is required.'},
);

Response _forbidden() => Response.json(
  statusCode: 403,
  body: {'message': 'Only merchants can manage products.'},
);
