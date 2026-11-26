import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/details_screen.dart';

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {super.key});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          product.thumbnail,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      ),
      title: Text(product.title),
      subtitle: Text('\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailsScreen(productId: product.id)),
      ),
    );
  }
}
