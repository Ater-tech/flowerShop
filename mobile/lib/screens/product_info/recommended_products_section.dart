import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mobile/providers/recommended_products_providers.dart';
import 'package:mobile/screens/home_screen/product_cart/card_product.dart';
class RecommendedProductsSection extends ConsumerWidget {
  const RecommendedProductsSection({super.key, required this.excludeProductId});
  final int excludeProductId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(recommendedProductsProvider(excludeProductId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sizga tavsiya etamiz', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        switch (productsAsync) {
          AsyncData(value: final value) when value.isEmpty =>
            const SizedBox(),
          AsyncData(value: final value) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, i) => ProductCard(product: value[i]),
            ),
          AsyncError() => const SizedBox(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}