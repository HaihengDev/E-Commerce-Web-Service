import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:app/config/db.dart';
import 'package:app/models/product_model.dart';
import 'package:app/repositories/product_repository.dart';
import 'package:app/services/product_service.dart';

Future<ProductService> _service() async {
  final db = await Database.connection;

  final repository = ProductRepository(db);

  return ProductService(repository, db);
}

Future<Response> onRequest(RequestContext context) async {
  final service = await _service();
  final request = context.request;

  switch (context.request.method) {
    case HttpMethod.get:
      return _readAllProducts(context, service);
    case HttpMethod.post:
      return _createProduct(context, service, request);
    default:
      return Response.json(
        statusCode: 405,
        body: {'message': 'There is no method.'},
      );
  }
}

Future<Response> _readAllProducts(
  RequestContext context,
  ProductService service,
) async {
  try {
    final products = await service.getAll();

    return Response.json(
      body: products.map((product) {
        return product.toJson();
      }).toList(),
    );
  } on ArgumentError catch (e) {
    return Response.json(statusCode: 405, body: {'message': e.message});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Internal Server Error', 'error': e.toString()},
    );
  }
}

Future<Response> _createProduct(
  RequestContext context,
  ProductService service,
  Request request,
) async {
  try {
    // 1. Read the request body
    final body = await request.body();

    // 2. Decode JSON
    final dynamic decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Request body must be a JSON object.'},
      );
    }

    final json = decoded;

    // 3. Validate required fields and types
    final productName = json['product_name'];
    final imgUrl = json['imgUrl'];
    final stock = json['stock'];
    final discount = json['discount'];
    final price = json['price'];
    final description = json['description'];
    final category = json['category'];

    if (productName is! String ||
        imgUrl is! String ||
        stock is! int ||
        discount is! int ||
        (price is! num) ||
        description is! String ||
        category is! String) {
      return Response.json(
        statusCode: 400,
        body: {
          'message': 'Missing or invalid product fields.',
        },
      );
    }

    // 4. Build product data
    final productData = Product.fromJson({
      'product_name': productName,
      'imgUrl': imgUrl,
      'stock': stock,
      'discount': discount,
      'price': price.toDouble(),
      'description': description,
      'category': category,
    });

    // 5. Call service layer
    final productCreated = await service.add(productData);

    // 6. Return success response
    return Response.json(
      statusCode: 201,
      body: {
        'result': productCreated,
        'message': 'Product created successfully.',
      },
    );
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
      body: {
        'message': 'Internal Server Error.',
        'error': e.toString(),
      },
    );
  }
}
