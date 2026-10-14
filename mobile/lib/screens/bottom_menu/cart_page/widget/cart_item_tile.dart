import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/cart_item_model.dart';
import 'package:mobile/providers/cart_provider/cart_provider.dart';

class CartItemTile extends ConsumerStatefulWidget {
  const CartItemTile({super.key, required this.item});
  final CartItemModel item;
  @override
  ConsumerState<CartItemTile> createState() => _CartItemState();
}

class _CartItemState extends ConsumerState<CartItemTile> {
  bool _busy = false;
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirishni tasdiqlang"),
        content: Text("\"${widget.item.displayName}\" savatdan o'chirilsinmi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );

    // Dialog yopilguncha widget dispose bo'lib qolgan bo'lishi mumkin
    if (confirmed != true || !mounted) return;

    final controller = ref.read(cartControllerProvider.notifier);
    await _run(() => controller.removeItem(widget.item.id));
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(cartControllerProvider.notifier);
    final item = widget.item;
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
                onPressed: (_busy || item.quantity > 1)
                    ? () => _run(
                        () => controller.updateQuantity(
                          item.id,
                          item.quantity - 1,
                        ),
                      )
                    : null,
              ),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: _busy
                      ? const SizedBox(
                          key: ValueKey("loading"),
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(),
                        )
                      : Text('${item.quantity}'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _run(
                  () => controller.updateQuantity(item.id, item.quantity + 1),
                ),
              ),
            ] else
              Text('× ${item.quantity}'),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _busy ? null : _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }
}