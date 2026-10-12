import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/data/order_enums.dart';
import '../../../../models/data/order_model.dart';
import '../../../../error_handler/orders_deps.dart';
import '../../../../providers/order_providers/checkout_controller.dart';
import '../widgets/order_card.dart' show formatDateTime, formatMoney, methodIcon;

/// Savatdagi mahsulotlar do'kon bo'yicha guruhlanib, shu sahifaga beriladi.
/// Guruhlash: cartItem.product.shop (yoki bouquet_detail.shop) id si bo'yicha;
/// [options] = shop.fulfillment_options (backend ShopSerializer'dan keladi).
class CheckoutShopGroup {
  const CheckoutShopGroup({
    required this.shopId,
    required this.shopName,
    required this.options,
    required this.lines,
    required this.subtotal,
  });
  final int shopId;
  final String shopName;
  final List<FulfillmentMethod> options;
  final List<String> lines; // masalan: "Atirgul dastasi × 2"
  final double subtotal;
}

class _Draft {
  _Draft(this.method);
  FulfillmentMethod method;
  final TextEditingController note = TextEditingController();
  DateTime? desiredAt;
}

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key, required this.groups});
  final List<CheckoutShopGroup> groups;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  late final Map<int, _Draft> _drafts = {
    for (final g in widget.groups) g.shopId: _Draft(g.options.first),
  };

  @override
  void dispose() {
    for (final d in _drafts.values) {
      d.note.dispose();
    }
    super.dispose();
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pickDateTime(_Draft d) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: d.desiredAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(d.desiredAt ?? now.add(const Duration(hours: 2))),
    );
    if (time == null) return;
    setState(() => d.desiredAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _submit() async {
    final selections = <ShopSelection>[];
    for (final g in widget.groups) {
      final d = _drafts[g.shopId]!;
      if (d.method == FulfillmentMethod.meetup && d.note.text.trim().isEmpty) {
        _snack("${g.shopName}: uchrashuv joyini yozing");
        return;
      }
      if (d.desiredAt != null && d.desiredAt!.isBefore(DateTime.now())) {
        _snack("${g.shopName}: vaqt kelajakda bo'lishi kerak");
        return;
      }
      selections.add(ShopSelection(
        shopId: g.shopId,
        method: d.method,
        meetupNote: d.note.text.trim(),
        desiredAt: d.desiredAt,
      ));
    }

    final result = await ref.read(checkoutControllerProvider.notifier).submit(selections);
    if (!mounted) return;
    switch (result) {
      case Success():
        _snack("So'rov yuborildi. Sotuvchi javobini kuting.");
        Navigator.of(context).pop(true);
      case Error(:final failure):
        _snack(failureMessage(failure));
    }
  }

  static String _hint(FulfillmentMethod m) => switch (m) {
        FulfillmentMethod.pickup => "Mahsulotni sotuvchi manzilidan o'zingiz olib ketasiz.",
        FulfillmentMethod.taxi =>
          "Taxini o'zingiz chaqirasiz va sotuvchi manzilini haydovchiga berasiz. Taxi haqini siz to'laysiz.",
        FulfillmentMethod.sellerDelivery => "Sotuvchi o'zi yetkazib beradi.",
        FulfillmentMethod.meetup =>
          "Qulay joyni yozing. Sotuvchi rozi bo'lsa, shu yerda uchrashasiz.",
      };

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(checkoutControllerProvider);
    final total = widget.groups.fold<double>(0, (s, g) => s + g.subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmani rasmiylashtirish')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final g in widget.groups) _shopCard(g),
          const SizedBox(height: 4),
          Text(
            "Ilova ichida to'lov yo'q: pul va mahsulot almashuvi uchrashganda amalga oshadi. "
            "Mahsulotni olmasdan to'lamang, pulni olmasdan mahsulotni topshirmang.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: submitting ? null : _submit,
            child: submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text("So'rov yuborish • ${formatMoney(total)}"),
          ),
        ),
      ),
    );
  }

  Widget _shopCard(CheckoutShopGroup g) {
    final d = _drafts[g.shopId]!;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(g.shopName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            for (final line in g.lines) Text(line),
            const Divider(height: 22),
            Text('Qanday olasiz?', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final m in g.options)
                  ChoiceChip(
                    avatar: Icon(methodIcon(m), size: 18),
                    label: Text(m.label),
                    selected: d.method == m,
                    onSelected: (_) => setState(() => d.method = m),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_hint(d.method), style: theme.textTheme.bodySmall),
            if (d.method == FulfillmentMethod.meetup) ...[
              const SizedBox(height: 10),
              TextField(
                controller: d.note,
                maxLength: 255,
                decoration: const InputDecoration(
                  labelText: 'Uchrashuv joyi',
                  hintText: "Masalan: Chilonzor metro chiqishida",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => _pickDateTime(d),
              icon: const Icon(Icons.schedule),
              label: Text(d.desiredAt == null
                  ? 'Qachon kerak? (ixtiyoriy)'
                  : formatDateTime(d.desiredAt!)),
            ),
          ],
        ),
      ),
    );
  }
}
