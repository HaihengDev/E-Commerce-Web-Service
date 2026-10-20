import 'package:merchant_service/services/service_client.dart';

class MerchantService {
  MerchantService({ServiceClient? client})
    : _client = client ?? ServiceClient();

  final ServiceClient _client;

  Future<ServiceResponse> products(
    String method, {
    String? id,
    Map<String, dynamic>? body,
  }) => _client.send('PRODUCT_SERVICE_URL', method, id: id, body: body);

  Future<ServiceResponse> categories(
    String method, {
    String? id,
    Map<String, dynamic>? body,
  }) => _client.send('CATEGORY_SERVICE_URL', method, id: id, body: body);

  Future<ServiceResponse> deleteCategory(String id) async {
    final productResponse = await products('GET');
    if (productResponse.statusCode != 200) {
      return ServiceResponse(502, {
        'message': 'Could not verify that the category is unused.',
      });
    }

    final items = productResponse.body;
    if (items is List &&
        items.any(
          (item) => item is Map<String, dynamic> && item['category'] == id,
        )) {
      return ServiceResponse(409, {
        'message': 'Category is assigned to one or more products.',
      });
    }
    return categories('DELETE', id: id);
  }
}
