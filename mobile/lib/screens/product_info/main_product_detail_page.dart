import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/providers/product_provider/product_detail_provider.dart';
import 'package:mobile/providers/search_providers.dart';
import 'package:mobile/screens/product_info/product_info_container.dart';
import 'product_sliver_app_bar.dart';
import 'add_to_cart_bar.dart';
import 'price_section.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    ref.listen<AsyncValue<ProductModel>>(productDetailProvider(productId), (
      prev,
      next,
    ) {
      final product = next.value;
      if (product != null && prev?.value?.id != product.id) {
        ref.read(recentlyViewedControllerProvider.notifier).add(product);
      }
    });
    return Scaffold(
      bottomNavigationBar: productAsync.value == null
          ? null
          : AddToCartBar(product: productAsync.value!),
      body: switch (productAsync) {
        AsyncData(:final value) => CustomScrollView(
          slivers: [
            ProductSliverAppBar(product: value),
            SliverToBoxAdapter(child: PriceSection(product: value)),
            SliverToBoxAdapter(child: ProductInfoContainer(product: value)),
          ],
        ),
        AsyncError(:final error) => Center(child: Text("Xatolik: $error")),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
