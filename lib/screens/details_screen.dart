import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/details_cubit.dart';
import '../data/product_api.dart';
import '../models/product.dart';
import '../widgets/error_view.dart';
import '../widgets/stars.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => DetailsCubit(c.read<ProductApi>())..load(productId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: BlocBuilder<DetailsCubit, DetailsState>(
          builder: (context, state) => switch (state) {
            DetailsLoading() => const Center(child: CircularProgressIndicator()),
            DetailsError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<DetailsCubit>().load(productId),
              ),
            DetailsLoaded(:final product) => _DetailsBody(product),
          },
        ),
      ),
    );
  }
}

String _date(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class _DetailsBody extends StatelessWidget {
  const _DetailsBody(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final images = product.images.isEmpty ? [product.thumbnail] : product.images;
    final d = product.dimensions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => Image.network(
              images[i],
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 220,
                child: Center(child: Icon(Icons.broken_image, size: 48)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(product.title, style: text.headlineSmall),
        Text('\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}'),
        const SizedBox(height: 12),
        Text(product.description),
        const SizedBox(height: 12),
        Text('Dimensions: ${d.width} × ${d.height} × ${d.depth}'),
        const Divider(height: 32),
        Text('Reviews (${product.reviews.length})', style: text.titleMedium),
        for (final r in product.reviews)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(children: [Stars(r.rating), const SizedBox(width: 8), Text(r.reviewerName)]),
            subtitle: Text('${_date(r.date)}\n${r.comment}'),
            isThreeLine: true,
          ),
      ],
    );
  }
}
