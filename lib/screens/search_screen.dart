import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../data/product_api.dart';
import '../widgets/error_view.dart';
import '../widgets/product_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => SearchBloc(c.read<ProductApi>()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => context.read<SearchBloc>().add(SearchSubmitted(_controller.text));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(hintText: 'Search products', border: InputBorder.none),
          onSubmitted: (_) => _submit(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
            onPressed: () {
              _controller.clear();
              context.read<SearchBloc>().add(const SearchCleared());
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => switch (state) {
          SearchIdle() => const Center(child: Text('Type a product name and press search.')),
          SearchLoading() => const Center(child: CircularProgressIndicator()),
          SearchEmpty(:final query) => Center(child: Text('No products found for "$query".')),
          SearchError(:final message) => ErrorView(message: message, onRetry: _submit),
          SearchResults(:final products) => ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) => ProductTile(products[i]),
            ),
        },
      ),
    );
  }
}
