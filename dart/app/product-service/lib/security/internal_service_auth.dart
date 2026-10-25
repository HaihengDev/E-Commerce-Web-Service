import 'package:dotenv/dotenv.dart' as dotenv;

bool hasValidInternalServiceToken(Map<String, String> headers) {
  final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
  final expected = env['INTERNAL_SERVICE_TOKEN'];
  final supplied = headers['x-internal-service-token'];
  if (expected == null || expected.length < 32 || supplied == null) {
    return false;
  }
  return _constantTimeEquals(expected, supplied);
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return difference == 0;
}
