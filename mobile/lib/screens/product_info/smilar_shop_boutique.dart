import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/shop_products_provider.dart';
import 'package:mobile/screens/home_screen/product_cart/card_product.dart';

class SimilarShopBouquetsSection extends ConsumerWidget {
  const SimilarShopBouquetsSection({super.key, required this.shopId});
  final int shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(shopProductsProvider(shopId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shopdagi boshqa guldastalar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: switch (productsAsync) {
            AsyncData(:final value) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: value.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => ProductCard(product: value[i]),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}