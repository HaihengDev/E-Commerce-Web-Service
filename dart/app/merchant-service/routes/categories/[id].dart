import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:merchant_service/services/merchant_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final service = MerchantService();
  switch (context.request.method) {
    case HttpMethod.get:
      return await _call(() => service.categories('GET', id: id));
    case HttpMethod.put:
      try {
        final body = await _readJson(context.request);
        return await _call(() => service.categories('PUT', id: id, body: body));
      } on FormatException catch (error) {
        return Response.json(statusCode: 400, body: {'message': error.message});
      }
    case HttpMethod.delete:
      return await _call(() => service.deleteCategory(id));
    default:
      return Response.json(
        statusCode: 405,
        body: {'message': 'Method not allowed.'},
      );
  }
}

Future<Response> _call(Future<dynamic> Function() action) async {
  try {
    final result = await action();
    return Response.json(
      statusCode: result.statusCode as int,
      body: result.body,
    );
  } catch (error) {
    return Response.json(
      statusCode: 502,
      body: {
        'message': 'Merchant dependency unavailable.',
        'error': error.toString(),
      },
    );
  }
}

Future<Map<String, dynamic>> _readJson(Request request) async {
  final value = jsonDecode(await request.body());
  if (value is! Map<String, dynamic>)
    throw const FormatException('Request body must be a JSON object.');
  return value;
}
