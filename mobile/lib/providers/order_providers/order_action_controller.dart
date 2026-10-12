import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/data/order_enums.dart';
import '../../repository/orders_repository.dart';
import '../../error_handler/orders_deps.dart';
import 'orders_providers.dart';

/// Ikki marta bosishdan himoya: amal bajarilayotgan buyurtma id'lari.
final orderActionPendingIdsProvider = StateProvider<Set<int>>((ref) => <int>{});

class OrderActionController extends Notifier<void> {
  @override
  void build() {}

  /// Muvaffaqiyatli bo'lsa null, aks holda Failure qaytaradi (UI snackbar ko'rsatadi).
  Future<Failure?> run(int orderId, OrderAction action) async {
    final pending = ref.read(orderActionPendingIdsProvider.notifier);
    if (pending.state.contains(orderId)) return null;
    pending.state = {...pending.state, orderId};

    final result = await ref.read(ordersRepositoryProvider).performAction(orderId, action);

    pending.state = {...pending.state}..remove(orderId);
    // Holat o'zgardi: ikkala oyna ham yangilansin (fire-and-forget)
    ref.invalidate(buyingOrdersProvider);
    ref.invalidate(sellingOrdersProvider);

    return switch (result) {
      Success() => null,
      Error(:final failure) => failure,
    };
  }
}

final orderActionControllerProvider =
    NotifierProvider<OrderActionController, void>(OrderActionController.new);
