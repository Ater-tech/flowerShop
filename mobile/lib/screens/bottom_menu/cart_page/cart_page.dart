import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/providers/button_nav_bar/orders_provider.dart';
// import 'package:mobile/screens/home_screen/product_cart/card_product.dart';
// mavjud mahsulot rasmi/kartochka widgeti importi

import '/models/cart_item_model.dart';
import '/providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savat')),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Yuklab bo'lmadi",
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => ref.invalidate(cartControllerProvider),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Text(
                  'Savat bo\'sh',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : _CartBody(items: items),
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({required this.items});
  final List<CartItemModel> items;

  // Do'kon bo'yicha guruhlash (faqat tayyor mahsulotlar; custom dasta
  // builder UI qurilgach, uning ham shop_id'si qo'shiladi).
  Map<int, List<CartItemModel>> _groupByShop() {
    final map = <int, List<CartItemModel>>{};
    for (final item in items) {
      final key = item.shopId ?? -1; // -1: shop aniqlanmagan (custom dasta)
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = _groupByShop();
    final total = ref.watch(cartTotalProvider);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in groups.entries) ...[
                Text(
                  entry.key == -1 ? 'Maxsus dastalar' : 'Do\'kon #${entry.key}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in entry.value) _CartItemTile(item: item),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        _CheckoutBar(total: total),
      ],
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cartControllerProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.product?.imageUrl ?? '',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.local_florist, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.unitPrice.toStringAsFixed(0)} so'm",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (!item.isBouquet) ...[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: item.quantity > 1
                    ? () =>
                          controller.updateQuantity(item.id, item.quantity - 1)
                    : null,
              ),
              Text('${item.quantity}'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () =>
                    controller.updateQuantity(item.id, item.quantity + 1),
              ),
            ] else
              Text('× ${item.quantity}'),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => controller.removeItem(item.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({required this.total});
  final double total;

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.checkout();
    if (!context.mounted) return;

    switch (result) {
      case Success():
        ref.invalidate(cartControllerProvider);
        ref.invalidate(myOrdersProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Buyurtma qabul qilindi')));
        Navigator.of(
          context,
        ).pop(); // Buyurtmalar tabiga qaytish — shellga moslash kere
      case Error():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Buyurtma berib bo'lmadi, qayta urining"),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Jami: ${total.toStringAsFixed(0)} so'm",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _checkout(context, ref),
              child: const Text('Buyurtma berish'),
            ),
          ],
        ),
      ),
    );
  }
}
