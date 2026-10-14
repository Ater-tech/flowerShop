import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/providers/button_nav_bar/orders_provider.dart';
// import 'package:mobile/screens/home_screen/product_cart/card_product.dart';
// mavjud mahsulot rasmi/kartochka widgeti importi

import '/models/cart_item_model.dart';
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
        _CheckoutBar(
          total: total,
          shopIds: groups.keys.where((k)=> k!= -1).toList(),
          ),
      ],
    );
  }
}

class _CartItemTile extends ConsumerStatefulWidget {
  const _CartItemTile({required this.item});
  final CartItemModel item;
  @override
  ConsumerState<_CartItemTile> createState() => _CartItemState();
}

class _CartItemState extends ConsumerState<_CartItemTile> {
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

class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({
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


const _methods = {
  'pickup': 'Borib olish',
  'taxi': 'Taxi orqali',
  'seller_delivery': 'Sotuvchi yetkazadi',
  'meetup': 'Kelishilgan joyda',
};

Future<List<Map<String, dynamic>>?> showFulfillmentSheet(
  BuildContext context,
  List<int> shopIds,
) {
  return showModalBottomSheet<List<Map<String, dynamic>>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FulfillmentSheet(shopIds: shopIds),
  );
}

class _FulfillmentSheet extends StatefulWidget {
  const _FulfillmentSheet({required this.shopIds});
  final List<int> shopIds;
  @override
  State<_FulfillmentSheet> createState() => _FulfillmentSheetState();
}

class _FulfillmentSheetState extends State<_FulfillmentSheet> {
  late final Map<int, String> _method = {
    for (final id in widget.shopIds) id: 'pickup',
  };
  late final Map<int, TextEditingController> _notes = {
    for (final id in widget.shopIds) id: TextEditingController(),
  };
  String? _error;

  @override
  void dispose() {
    for (final c in _notes.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    for (final id in widget.shopIds) {
      if (_method[id] == 'meetup' && _notes[id]!.text.trim().isEmpty) {
        setState(() => _error = 'Uchrashuv joyini yozing');
        return;
      }
    }
    Navigator.of(context).pop([
      for (final id in widget.shopIds)
        {
          'shop': id,
          'fulfillment_method': _method[id],
          'meetup_note': _notes[id]!.text.trim(),
          'desired_at': null,
        },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final id in widget.shopIds) ...[
              Text("Do'kon #$id",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: _method[id],
                items: [
                  for (final e in _methods.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _method[id] = v!),
              ),
              if (_method[id] == 'meetup')
                TextField(
                  controller: _notes[id],
                  decoration:
                      const InputDecoration(labelText: 'Uchrashuv joyi'),
                ),
              const SizedBox(height: 12),
            ],
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Tasdiqlash'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}