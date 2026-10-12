import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/data/order_enums.dart';
import '../../../../models/data/order_model.dart';
import '../../../../error_handler/orders_deps.dart';
import '../../../../providers/order_providers/orders_providers.dart';
import '../widgets/order_card.dart';

String _errorText(Object e) => e is Failure ? failureMessage(e) : 'Xatolik yuz berdi';

/// Buyurtmalar bo'limi. Oynalar backend `meta.tabs` ga qarab chiqadi:
///  - oddiy xaridor:        faqat "Sotib olinganlar"
///  - yakka sotuvchi:       "Sotib olinganlar" + "Mahsulotlarim"
///  - rasmiy do'kon:        faqat "Mahsulotlarim"
class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key, this.onReview});

  final void Function(OrderModel order)? onReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(ordersMetaProvider);

    return meta.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Buyurtmalar')),
        body: _ErrorView(message: _errorText(e), onRetry: () => ref.invalidate(ordersMetaProvider)),
      ),
      data: (m) {
        final tabs = m.tabs;
        if (tabs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Buyurtmalar')),
            body: const Center(child: Text("Hozircha buyurtmalar yo'q")),
          );
        }
        if (tabs.length == 1) {
          return Scaffold(
            appBar: AppBar(title: Text(_tabLabel(tabs.first))),
            body: OrdersListView(role: tabs.first, onReview: onReview),
          );
        }
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Buyurtmalar'),
              bottom: TabBar(tabs: [for (final r in tabs) Tab(text: _tabLabel(r))]),
            ),
            body: TabBarView(
              children: [for (final r in tabs) OrdersListView(role: r, onReview: onReview)],
            ),
          ),
        );
      },
    );
  }

  static String _tabLabel(OrderRole r) =>
      r == OrderRole.buying ? 'Sotib olinganlar' : 'Mahsulotlarim';
}

/// Bitta oyna ro'yxati. Backend allaqachon tartiblab beradi:
/// faol tepada, arxiv pastda (ichida yangisi birinchi).
class OrdersListView extends ConsumerWidget {
  const OrdersListView({super.key, required this.role, this.productId, this.onReview});

  final OrderRole role;
  final int? productId;
  final void Function(OrderModel order)? onReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        role == OrderRole.buying ? buyingOrdersProvider : sellingOrdersProvider(productId);
    final async = ref.watch(provider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: _errorText(e), onRetry: () => ref.invalidate(provider)),
      data: (orders) {
        Future<void> refresh() async {
          ref.invalidate(provider);
          await ref.read(provider.future);
        }

        if (orders.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(children: const [
              SizedBox(height: 160),
              Center(child: Text("Hozircha buyurtmalar yo'q")),
            ]),
          );
        }

        final firstArchived = orders.indexWhere((o) => o.isCompleted);
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final card = OrderCard(order: orders[i], onReview: onReview);
              if (i != firstArchived) return card;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text('Bajarilganlar',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Theme.of(context).hintColor)),
                  ),
                  card,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// "Mahsulotlarim" ro'yxatidagi mahsulot bosilganda: shu mahsulotga kelgan so'rovlar.
class SellerProductOrdersPage extends StatelessWidget {
  const SellerProductOrdersPage({super.key, required this.productId, required this.title});

  final int productId;
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: OrdersListView(role: OrderRole.selling, productId: productId),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Qayta urinish')),
          ],
        ),
      );
}
