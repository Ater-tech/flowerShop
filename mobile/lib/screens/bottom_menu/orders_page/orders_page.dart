import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/screens/crud_product/update_product/update_page.dart';
// import 'package:mobile/models/product_model.dart';
import 'package:mobile/screens/home_screen/product_cart/widget/product_card.dart';

import 'package:mobile/models/button_nav_bar/order_model.dart';
import 'package:mobile/providers/button_nav_bar/orders_provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyurtmalarim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Buyurtmalar'),
            Tab(text: 'Mahsulotlarim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OrdersTab(), _MyProductsTab()],
      ),
    );
  }
}

// ───────────────────────── Buyurtmalar tabi ─────────────────────────

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(myOrdersProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              _ErrorState(onRetry: () => ref.invalidate(myOrdersProvider)),
          data: (orders) => orders.isEmpty
              ? const _EmptyState(text: "Hali buyurtma yo'q")
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                ),
        );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  static const _statusLabels = {
    'new': 'Yangi',
    'accepted': 'Qabul qilindi',
    'delivering': 'Yetkazilmoqda',
    'completed': 'Bajarildi',
    'cancelled': 'Bekor qilindi',
  };

  @override
  Widget build(BuildContext context) {
    // Bajarilgan/bekor qilingan buyurtmalar xiralashgan ko'rinadi.
    // Backend ularni ro'yxat oxirida qaytaradi (buyer_orders selector).
    return Opacity(
      opacity: order.isCompleted ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buyurtma #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabels[order.status] ?? order.status,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('${item.nameSnapshot} × ${item.quantity}'),
                ),
              const SizedBox(height: 8),
              Text(
                "Jami: ${order.totalPrice.toStringAsFixed(0)} so'm",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Mahsulotlarim tabi ─────────────────────────

class _MyProductsTab extends ConsumerWidget {
  const _MyProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(myProductsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              _ErrorState(onRetry: () => ref.invalidate(myProductsProvider)),
          data: (products) => products.isEmpty
              ? const _EmptyState(text: "Hali mahsulot qo'shilmagan")
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 230,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    //`status`/`available` maydon nomlari ProductModel
                    final isFaded =
                        p.status != 'active' || p.available == false;
                    return Opacity(
                      opacity: isFaded ? 0.5 : 1.0,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductPage(product: p),
                          ),
                        ),
                        child: ProductCard(product: p),
                      ), //ProductCard(product: p)
                    );
                  },
                ),
        );
  }
}

// ───────────────────────── Umumiy holatlar ─────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Yuklab bo'lmadi", style: TextStyle(color: Colors.grey)),
          TextButton(onPressed: onRetry, child: const Text('Qayta urinish')),
        ],
      ),
    );
  }
}
