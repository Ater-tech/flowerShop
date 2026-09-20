import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/product_search_providers.dart';
import 'package:mobile/screens/home_screen/product_cart/card_product.dart';

const double _kCardHeight = 230; // kartochkangiz balandligiga moslang

/// Qidiruv natijalari — sliver qaytaradi, shuning uchun CustomScrollView
/// ichida to'g'ridan-to'g'ri ishlatiladi.
class SearchResultsSliver extends ConsumerWidget {
  const SearchResultsSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // productListProvider: rawSearchInput → debouncer → effectiveQuery zanjiridan
    // keladi. List<ProductModel> qaytaradi.
    return ref.watch(productListProvider).when(
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Yuklab bo'lmadi", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => ref.invalidate(productListProvider),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
          ),
          data: (products) => products.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Hech narsa topilmadi', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: _kCardHeight,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductCard(product: products[i]), 
                  ),
                ),
        );
  }
}