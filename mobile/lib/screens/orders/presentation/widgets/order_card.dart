import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/data/order_enums.dart';
import '../../../../models/data/order_model.dart';
import '../../../../error_handler/orders_deps.dart';
import '../../../../providers/order_providers/order_action_controller.dart';

String formatMoney(double v) =>
    "${v.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ')} so'm";

String formatDateTime(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}

IconData methodIcon(FulfillmentMethod m) => switch (m) {
      FulfillmentMethod.pickup => Icons.directions_walk,
      FulfillmentMethod.taxi => Icons.local_taxi_outlined,
      FulfillmentMethod.sellerDelivery => Icons.delivery_dining,
      FulfillmentMethod.meetup => Icons.place_outlined,
    };

class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order, this.onReview});

  final OrderModel order;

  /// Baho/sharh oynasini ochish (reviews feature'ingiz bilan ulang).
  final void Function(OrderModel order)? onReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pending = ref.watch(orderActionPendingIdsProvider).contains(order.id);

    final title = order.isSelling
        ? (order.counterparty?.name ?? "Xaridor so'rovi")
        : order.shopInfo.name;

    // Xaridorga sotuvchi manzili kerak: borib olish, taxi, uchrashuv uchun (kelishuvdan keyin)
    final showAddress = !order.isSelling &&
        order.stage != OrderStage.pending &&
        !order.isCompleted &&
        order.fulfillmentMethod != FulfillmentMethod.sellerDelivery &&
        order.shopInfo.address.isNotEmpty;

    return Opacity(
      opacity: order.isCompleted ? 0.55 : 1, // arxiv: xira
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  _StageChip(label: order.stageLabel, stage: order.stage),
                ],
              ),
              const SizedBox(height: 8),
              for (final i in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text('${i.name} × ${i.quantity}'),
                ),
              const Divider(height: 20),
              _InfoRow(
                icon: methodIcon(order.fulfillmentMethod),
                text: order.fulfillmentMethod.label,
              ),
              if (order.desiredAt != null)
                _InfoRow(icon: Icons.schedule, text: 'Kerak vaqti: ${formatDateTime(order.desiredAt!)}'),
              if (order.meetupNote.isNotEmpty)
                _InfoRow(icon: Icons.place_outlined, text: order.meetupNote),
              if (showAddress)
                _InfoRow(icon: Icons.storefront_outlined, text: order.shopInfo.address),
              if (order.counterparty?.phone != null)
                _PhoneRow(phone: order.counterparty!.phone!),
              if (order.notices.isNotEmpty) ...[
                const SizedBox(height: 8),
                OrderNoticesBox(notices: order.notices),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(formatMoney(order.totalPrice),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (order.actions.isNotEmpty || (order.canReview && onReview != null)) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in order.actions)
                      _ActionButton(
                        order: order,
                        action: a,
                        busy: pending,
                        onPressed: () => _run(context, ref, a),
                      ),
                    if (order.canReview && onReview != null)
                      TextButton.icon(
                        onPressed: () => onReview!(order),
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Baho va sharh qoldirish'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, OrderAction action) async {
    final question = _confirmText(action);
    if (question != null) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(question),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Yo\'q')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ha')),
          ],
        ),
      );
      if (ok != true) return;
    }
    final failure = await ref.read(orderActionControllerProvider.notifier).run(order.id, action);
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage(failure))));
    }
  }

  String? _confirmText(OrderAction a) => switch (a) {
        OrderAction.accept => null,
        OrderAction.reject => "So'rovni rad etasizmi?",
        OrderAction.cancel => 'Buyurtmani bekor qilasizmi?',
        OrderAction.complete => order.isSelling
            ? 'Mahsulotni topshirganingizni tasdiqlaysizmi?'
            : 'Mahsulotni olganingizni tasdiqlaysizmi?',
      };
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.order,
    required this.action,
    required this.busy,
    required this.onPressed,
  });
  final OrderModel order;
  final OrderAction action;
  final bool busy;
  final VoidCallback onPressed;

  String get _label => switch (action) {
        OrderAction.accept => 'Qabul qilish',
        OrderAction.reject => 'Rad etish',
        OrderAction.cancel => 'Bekor qilish',
        OrderAction.complete => order.isSelling ? 'Topshirdim' : 'Oldim',
      };

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(_label);
    final negative = action == OrderAction.reject || action == OrderAction.cancel;
    if (negative) {
      return OutlinedButton(
        onPressed: busy ? null : onPressed,
        style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
        child: child,
      );
    }
    return FilledButton(onPressed: busy ? null : onPressed, child: child);
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.label, required this.stage});
  final String label;
  final OrderStage stage;

  @override
  Widget build(BuildContext context) {
    final color = switch (stage) {
      OrderStage.pending => Colors.amber.shade800,
      OrderStage.incoming || OrderStage.pickupInProgress => Colors.blue.shade700,
      OrderStage.agreed => Colors.green.shade700,
      OrderStage.archived => Colors.grey.shade600,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).hintColor),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(Icons.phone_outlined, size: 18, color: Theme.of(context).hintColor),
          const SizedBox(width: 8),
          Expanded(child: Text(phone)),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Nusxa olish',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Raqam nusxalandi')));
            },
          ),
        ],
      );
}

/// Kelishuvdan keyingi xavfsizlik eslatmalari (taxi / dostavka / uchrashuv).
class OrderNoticesBox extends StatelessWidget {
  const OrderNoticesBox({super.key, required this.notices});
  final List<OrderNotice> notices;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final n in notices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: scheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(child: Text(n.text, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
