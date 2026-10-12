import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/data/order_enums.dart';
import '../../models/data/order_model.dart';
import '../../repository/orders_repository.dart';
import '../../error_handler/orders_deps.dart';

/// Qaysi oynalar ko'rinadi va xarid qila oladimi (backend: GET /api/orders/meta/).
final ordersMetaProvider = FutureProvider.autoDispose<OrdersMeta>((ref) async {
  final result = await ref.watch(ordersRepositoryProvider).fetchMeta();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// "Savatga" tugmasini yashirish uchun. Yuklanguncha true (tugma miltillamasligi uchun);
/// haqiqiy himoya baribir backend'da.
final canBuyProvider = Provider.autoDispose<bool>((ref) {
  final meta = ref.watch(ordersMetaProvider);
  return meta.maybeWhen(data: (m) => m.canBuy, orElse: () => true);
});

/// Oyna 1: Sotib olinganlar.
final buyingOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final result = await ref.watch(ordersRepositoryProvider).fetchOrders(OrderRole.buying);
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// Oyna 2: Sotuvchi tomoni. [productId] berilsa, faqat shu mahsulotga kelgan so'rovlar.
final sellingOrdersProvider =
    FutureProvider.autoDispose.family<List<OrderModel>, int?>((ref, productId) async {
  final result = await ref
      .watch(ordersRepositoryProvider)
      .fetchOrders(OrderRole.selling, productId: productId);
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});
