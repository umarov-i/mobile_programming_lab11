import 'package:api_catalog/data/product_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'test_helpers.dart';

void main() {
  test('getProducts returns one product from a mocked page', () async {
    final page = await apiAnswering(200, pageJson()).getProducts();
    expect(page.products, hasLength(1));
    expect(page.products.first.title, 'Essence Mascara Lash Princess');
  });

  test('getProduct throws ApiException on 404', () {
    final api = apiAnswering(404, {'message': "Product with id '0' not found"});
    expect(api.getProduct(0), throwsA(isA<ApiException>()));
  });

  test('lost connection becomes an ApiException', () {
    expect(apiOffline().getProducts(), throwsA(isA<ApiException>()));
  });

  test('invalid JSON becomes an ApiException', () {
    final api = ProductApi(client: MockClient((_) async => http.Response('not json', 200)));
    expect(api.getProducts(), throwsA(isA<ApiException>()));
  });
}
