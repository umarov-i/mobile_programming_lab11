import 'package:api_catalog/models/product.dart';
import 'package:api_catalog/models/product_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  test('Product.fromJson parses the saved fixture', () {
    final p = Product.fromJson(loadFixture());

    expect(p.title, 'Essence Mascara Lash Princess');
    expect(p.price, isA<double>());
    expect(p.price, 9.99);
    expect(p.tags, ['beauty', 'mascara']);
    expect(p.reviews, hasLength(3));
    expect(p.reviews.first.date, isA<DateTime>());
    expect(p.dimensions.width, 23.17);
    expect(p.brand, 'Essence');
  });

  test('missing brand and tags do not crash; tags become an empty list', () {
    final p = Product.fromJson({
      'id': 2,
      'title': 'No brand',
      'description': 'd',
      'price': 10, // an int on purpose: must still become a double
      'rating': 4,
      'thumbnail': 'x',
      'dimensions': {'width': 1, 'height': 2, 'depth': 3},
    });

    expect(p.brand, isNull);
    expect(p.tags, isEmpty); // our documented decision
    expect(p.price, isA<double>());
    expect(p.reviews, isEmpty);
  });

  test('ProductPage.fromJson reuses Product.fromJson', () {
    final page = ProductPage.fromJson(pageJson());

    expect(page.products, hasLength(1));
    expect(page.total, 1);
    expect(page.limit, 20);
  });
}
