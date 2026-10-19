import 'dart:convert';
import 'dart:io';
import 'package:dotenv/dotenv.dart' as dotenv;

class CategoryClient {
  final HttpClient _client = HttpClient();

  Future<void> requireCategory(String categoryId) async {
    final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    final baseUrl =
        (env['CATEGORY_SERVICE_URL'] ?? 'http://localhost:8001/categories')
            .replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse('$baseUrl/${Uri.encodeComponent(categoryId)}');
    final request = await _client.getUrl(uri);
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode == HttpStatus.notFound) {
      throw ArgumentError('Product category does not exist.');
    }
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Category service returned ${response.statusCode}: $body',
      );
    }
  }
}
