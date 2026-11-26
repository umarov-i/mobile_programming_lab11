import 'package:api_catalog/cubit/products_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  blocTest<ProductsCubit, ProductsState>(
    'success: Loading then Loaded',
    build: () => ProductsCubit(apiAnswering(200, pageJson())),
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsLoaded>()],
  );

  blocTest<ProductsCubit, ProductsState>(
    'failure: Loading then Error',
    build: () => ProductsCubit(apiAnswering(500, {'message': 'boom'})),
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsError>()],
  );
}
