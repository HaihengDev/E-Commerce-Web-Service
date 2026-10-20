import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:merchant_service/services/merchant_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final service = MerchantService();
  final method = switch (context.request.method) {
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    _ => null,
  };
  if (method == null)
    return Response.json(
      statusCode: 405,
      body: {'message': 'Method not allowed.'},
    );
  try {
    final body = method == 'POST' ? await _readJson(context.request) : null;
    final result = await service.categories(method, body: body);
    return Response.json(statusCode: result.statusCode, body: result.body);
  } on FormatException catch (error) {
    return Response.json(statusCode: 400, body: {'message': error.message});
  } catch (error) {
    return Response.json(
      statusCode: 502,
      body: {
        'message': 'Category service unavailable.',
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
