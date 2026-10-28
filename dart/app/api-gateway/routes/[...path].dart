import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

final _client = HttpClient();

const _serviceEnvironmentKeys = <String, String>{
  'auth': 'AUTH_SERVICE_URL',
  'products': 'PRODUCT_SERVICE_URL',
  'categories': 'CATEGORY_SERVICE_URL',
  'orders': 'ORDER_SERVICE_URL',
  'payments': 'PAYMENT_SERVICE_URL',
  'merchant': 'MERCHANT_SERVICE_URL',
};

const _serviceDefaults = <String, String>{
  'auth': 'http://localhost:8003',
  'products': 'http://localhost:8000',
  'categories': 'http://localhost:8001/categories',
  'orders': 'http://localhost:8004',
  'payments': 'http://localhost:8005',
  'merchant': 'http://localhost:8002',
};

Future<Response> onRequest(RequestContext context, String path) async {
  final request = context.request;
  final segments = request.uri.pathSegments;

  if (segments.length < 3 ||
      segments[0] != 'api' ||
      segments[1] != 'v1') {
    return Response.json(
      statusCode: 404,
      body: {'message': 'Route not found.'},
    );
  }

  final service = segments[2];
  final environmentKey = _serviceEnvironmentKeys[service];
  if (environmentKey == null) {
    return Response.json(
      statusCode: 404,
      body: {'message': 'Unknown service.'},
    );
  }

  final remainingPath = segments.skip(3).join('/');
  final baseUrl = Platform.environment[environmentKey] ?? _serviceDefaults[service]!;
  final baseUri = Uri.parse(baseUrl);
  final targetUri = baseUri.replace(
    path: <String>[
      baseUri.path.replaceFirst(RegExp(r'/+$'), ''),
      if (remainingPath.isNotEmpty) remainingPath,
    ].where((part) => part.isNotEmpty).join('/'),
    query: request.uri.hasQuery ? request.uri.query : null,
    fragment: null,
  );

  try {
    final upstreamRequest = await _client.openUrl(
      request.method.name.toUpperCase(),
      targetUri,
    );
    request.headers.forEach((name, value) {
      if (!_hopByHopHeaders.contains(name.toLowerCase()) &&
          name.toLowerCase() != 'host' &&
          name.toLowerCase() != 'content-length') {
        upstreamRequest.headers.set(name, value);
      }
    });

    if (request.method != HttpMethod.get && request.method != HttpMethod.head) {
      upstreamRequest.add(utf8.encode(await request.body()));
    }

    final upstreamResponse = await upstreamRequest.close();
    final responseHeaders = <String, String>{};
    upstreamResponse.headers.forEach((name, values) {
      if (!_hopByHopHeaders.contains(name.toLowerCase()) &&
          name.toLowerCase() != 'content-length') {
        responseHeaders[name] = values.join(', ');
      }
    });

    return Response.bytes(
      body: await upstreamResponse.fold<List<int>>(
        <int>[],
        (bytes, chunk) => bytes..addAll(chunk),
      ),
      statusCode: upstreamResponse.statusCode,
      headers: responseHeaders,
    );
  } on SocketException {
    return Response.json(
      statusCode: 502,
      body: {'message': 'The requested service is unavailable.'},
    );
  } on HttpException {
    return Response.json(
      statusCode: 502,
      body: {'message': 'The requested service returned an invalid response.'},
    );
  }
}

const _hopByHopHeaders = <String>{
  'connection',
  'keep-alive',
  'proxy-authenticate',
  'proxy-authorization',
  'te',
  'trailer',
  'transfer-encoding',
  'upgrade',
};
