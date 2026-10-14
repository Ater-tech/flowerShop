import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/cart_item_model.dart';
import 'package:mobile/providers/cart_provider/cart_provider.dart';
import 'package:mobile/screens/bottom_menu/cart_page/widget/cart_item_tile.dart';
import 'package:mobile/screens/bottom_menu/cart_page/widget/check_out.dart';
class CartBody extends ConsumerWidget {
  const CartBody({super.key, required this.items});
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
                for (final item in entry.value) CartItemTile(item: item),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        CheckoutBar(
          total: total,
          shopIds: groups.keys.where((k)=> k!= -1).toList(),
          ),
      ],
    );
  }
}
