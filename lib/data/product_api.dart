import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _host = 'dummyjson.com';

  /// [delayMs] is only for experiments: DummyJSON waits that long.
  Future<ProductPage> getProducts({int limit = 20, int skip = 0, int? delayMs}) {
    final uri = Uri.https(_host, '/products', {
      'limit': '$limit',
      'skip': '$skip',
      if (delayMs != null) 'delay': '$delayMs',
    });
    return _get(uri, ProductPage.fromJson);
  }

  Future<Product> getProduct(int id) =>
      _get(Uri.https(_host, '/products/$id'), Product.fromJson);

  Future<ProductPage> search(String query, {int? delayMs}) {
    final uri = Uri.https(_host, '/products/search', {
      'q': query,
      if (delayMs != null) 'delay': '$delayMs',
    });
    return _get(uri, ProductPage.fromJson);
  }

  /// The one place that sends, checks, decodes and parses. Every failure
  /// leaves this method as an [ApiException].
  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) parse) async {
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw ApiException(_messageFor(response.statusCode));
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return parse(json);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('The server took too long to answer. Please try again.');
    } on http.ClientException {
      throw const ApiException('No connection. Check your internet and try again.');
    } on FormatException {
      throw const ApiException('The server sent data we could not read.');
    } on TypeError {
      // A cast in fromJson failed: the JSON shape is not what we expected.
      throw const ApiException('The server sent data in an unexpected format.');
    }
  }

  String _messageFor(int status) {
    if (status == 404) return 'Not found (404).';
    if (status >= 500) return 'The server has a problem ($status). Try again later.';
    return 'Server answered $status';
  }
}
