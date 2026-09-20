import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:mobile/providers/search_providers.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/screens/home_screen/product_cart/card_product.dart';
// o'zingizdagi mahsulot kartochkasi widgeti importi

// Kartochka o'lchamlari — o'zingizning kartochkangizga moslang.
const double _kCardWidth = 160;
const double _kRowHeight = 230;
const double _kGap = 12;

extension on SearchTab {
  String get label => switch (this) {
        SearchTab.recent => 'Oxirgi qidirilganlar',
        SearchTab.recommended => 'Tavsiya etilgan',
        SearchTab.popular => 'Mashhurlar',
      };
}

class DiscoverSection extends ConsumerWidget {
  const DiscoverSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(searchTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _TabBar(selected: tab),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          // Har bir tab o'z providerini o'zi kuzatadi (alohida widget).
          child: switch (tab) {
            SearchTab.recent => const _RecentTab(key: ValueKey('recent')),
            SearchTab.recommended => _AsyncProducts(
                key: const ValueKey('recommended'),
                provider: recommendedProductsProvider,
                onRetry: () => ref.invalidate(recommendedProductsProvider),
              ),
            SearchTab.popular => _AsyncProducts(
                key: const ValueKey('popular'),
                provider: popularProductsProvider,
                onRetry: () => ref.invalidate(popularProductsProvider),
              ),
          },
        ),
      ],
    );
  }
}

class _TabBar extends ConsumerWidget {
  const _TabBar({required this.selected});
  final SearchTab selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final tab in SearchTab.values) ...[
            ChoiceChip(
              label: Text(tab.label),
              selected: tab == selected,
              onSelected: (_) => ref.read(searchTabProvider.notifier).state = tab,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

// recentlyViewed kodingiz ulangach, shu yerda provider'ni kuzating.
class _RecentTab extends StatelessWidget {
  const _RecentTab({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Message("Hali hech narsa ko'rilmagan");
}

class _AsyncProducts extends ConsumerWidget {
  const _AsyncProducts({super.key, required this.provider, required this.onRetry});

  // ProviderListenable — autoDispose yoki oddiy provider, ikkalasi ham mos.
  final ProviderListenable<AsyncValue<List<ProductModel>>> provider;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(provider).when(
          loading: () => const SizedBox(
            height: _kRowHeight,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => _Message("Yuklab bo'lmadi", onRetry: onRetry),
          data: (products) => products.isEmpty
              ? const _Message("Hozircha mahsulot yo'q")
              : _ProductsGrid(products: products),
        );
  }
}

/// Yonga suriladigan, 2 qatorli grid.
class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid({required this.products});
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kRowHeight * 2 + _kGap,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 qator
          mainAxisSpacing: _kGap,
          crossAxisSpacing: _kGap,
          mainAxisExtent: _kCardWidth, // yonga qarab kenglik
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(product: products[i]), // product kartochka
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.onRetry});
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: const TextStyle(color: Colors.grey)),
            if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Qayta urinish')),
          ],
        ),
      ),
    );
  }
}