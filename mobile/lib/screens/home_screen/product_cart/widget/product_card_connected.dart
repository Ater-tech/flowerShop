import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_card.dart';
import 'package:mobile/models/product_model.dart';
import '../../application/favourite_providers.dart'; // keyin yozamiz

class ProductCardConnected extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCardConnected({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProductCard(
      product: product,
      onTap: onTap,
      onFavouriteTap: () {
        ref.read(favouriteControllerProvider.notifier).toggle(product);
      },
    );
  }
}
