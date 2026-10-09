import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/cart_item_model.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/providers/cart_provider.dart';
import 'package:mobile/screens/bottom_menu/cart_page/cart_page.dart';

class AddToCartBar extends ConsumerStatefulWidget {
  const AddToCartBar({super.key, required this.product});
  final ProductModel product;

  @override
  ConsumerState<AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends ConsumerState<AddToCartBar> {
  bool _busy = false; // qo'sh-bosishdan himoya (favourites'dagi pending kabi)

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productId = widget.product.id;

    // Shu mahsulotning savatdagi qatori (bo'lmasa null)
    final item = ref.watch(
      cartControllerProvider.select((state) {
        final items = state.value ?? const <CartItemModel>[];
        for (final i in items) {
          if (i.product?.id == productId) return i;
        }
        return null;
      }),
    );

    final controller = ref.read(cartControllerProvider.notifier);
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: item == null
            ? SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(shape: shape),
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                          final ok = await controller.addProduct(productId);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? "Mahsulot savatga qo'shildi"
                                      : "Mahsulotni savatga qo'shishda xatolik yuz berdi",
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                        }),
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.shopping_cart_outlined),
                  label: const Text(
                    "Savatga qo'shish",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            : Row(
                children: [
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _busy
                              ? null
                              : () => _run(
                                  () => item.quantity <= 1
                                      ? controller.removeItem(item.id)
                                      : controller.updateQuantity(
                                          item.id,
                                          item.quantity - 1,
                                        ),
                                ),
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _busy
                              ? null
                              : () => _run(
                                  () => controller.updateQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                                ),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(shape: shape),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Savatga o'tish",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
