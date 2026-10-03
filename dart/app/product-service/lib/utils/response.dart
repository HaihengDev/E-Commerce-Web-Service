import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

Response jsonResponse({
  required int statusCode,
  required dynamic data,
}) {
  return Response(
    statusCode: statusCode,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
}
