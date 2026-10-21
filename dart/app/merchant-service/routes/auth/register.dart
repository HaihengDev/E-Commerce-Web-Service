import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:merchant_service/services/merchant_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'message': 'Method not allowed.'},
    );
  }
  try {
    final body = jsonDecode(await context.request.body());
    if (body is! Map<String, dynamic>) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Request body must be a JSON object.'},
      );
    }
    final result = await MerchantService().auth('POST', 'register', body);
    return Response.json(statusCode: result.statusCode, body: result.body);
  } on FormatException {
    return Response.json(statusCode: 400, body: {'message': 'Invalid JSON.'});
  } catch (error) {
    return Response.json(
      statusCode: 502,
      body: {
        'message': 'Authentication service unavailable.',
        'error': error.toString(),
      },
    );
  }
}
