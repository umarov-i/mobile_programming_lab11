import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../widgets/error_view.dart';
import '../widgets/product_tile.dart';
import 'search_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) => switch (state) {
          ProductsLoading() => const Center(child: CircularProgressIndicator()),
          ProductsError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<ProductsCubit>().load(),
            ),
          ProductsLoaded() => _ProductList(state),
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList(this.state);
  final ProductsLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProductsCubit>().refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        // one extra row for the footer, only while more products exist
        itemCount: state.products.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i < state.products.length) return ProductTile(state.products[i]);
          return _LoadMoreFooter(state);
        },
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter(this.state);
  final ProductsLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (state.loadMoreError != null)
            Text(state.loadMoreError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          TextButton(
            onPressed: () => context.read<ProductsCubit>().loadMore(),
            child: Text('Load more (${state.products.length} of ${state.total})'),
          ),
        ],
      ),
    );
  }
}
