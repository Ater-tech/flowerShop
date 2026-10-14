import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/providers/button_nav_bar/orders_provider.dart';
import 'package:mobile/providers/cart_provider/cart_provider.dart';
import 'package:mobile/screens/bottom_menu/cart_page/widget/full_fill_sheet.dart';

class CheckoutBar extends ConsumerWidget {
  const CheckoutBar({
    super.key,
    required this.total,
    required this.shopIds,
    });
  final double total;
  final List<int> shopIds;

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final orders = await showFulfillmentSheet(context, shopIds);
    if(orders == null || !context.mounted) return;
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.checkout(orders);
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
