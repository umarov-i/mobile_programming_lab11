import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/data/product_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> loadFixture() =>
    jsonDecode(File('test/fixtures/product.json').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> pageJson() => {
      'products': [loadFixture()],
      'total': 1,
      'skip': 0,
      'limit': 20,
    };

ProductApi apiAnswering(int status, Object body) => ProductApi(
      client: MockClient((_) async => http.Response(
            jsonEncode(body),
            status,
            headers: {'content-type': 'application/json; charset=utf-8'},
          )),
    );

ProductApi apiOffline() => ProductApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
