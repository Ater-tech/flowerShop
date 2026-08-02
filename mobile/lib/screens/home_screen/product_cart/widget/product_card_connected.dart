// presentation/widgets/product_card_connected.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_card.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/providers/favourite_providers.dart';

class ProductCardConnected extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCardConnected({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingIds = ref.watch(favouritePendingIdsProvider);
    final isPending = pendingIds.contains(product.id);

    return ProductCard(
      product: product,
      onTap: onTap,
      isFavouriteLoading: isPending,
      onFavouriteTap: isPending
          ? null // so'rov ketayotganda tugma bosilmaydi
          : () => ref
                .read(favouriteControllerProvider.notifier)
                .toggle(product.id),
    );
  }
}
