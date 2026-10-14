import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget/cart_body.dart';

// import 'package:mobile/screens/home_screen/product_cart/card_product.dart';
// mavjud mahsulot rasmi/kartochka widgeti importi
import '../../../providers/cart_provider/cart_provider.dart';

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
            : CartBody(items: items),
      ),
    );
  }
}
