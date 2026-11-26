import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/products_cubit.dart';
import 'data/product_api.dart';
import 'screens/products_screen.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ProductApi(),
      child: MaterialApp(
        title: 'API Catalog',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: BlocProvider(
          create: (c) => ProductsCubit(c.read<ProductApi>())..load(),
          child: const ProductsScreen(),
        ),
      ),
    );
  }
}
