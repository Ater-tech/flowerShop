import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/cart_provider/cart_provider.dart';

import '../../models/data/order_model.dart';
import '../../repository/orders_repository.dart';
import '../../error_handler/orders_deps.dart';
import 'orders_providers.dart';

/// state = yuborilmoqdami (tugmani o'chirib turish uchun)
class CheckoutController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<Result<List<OrderModel>>> submit(List<ShopSelection> selections) async {
    state = true;
    final result = await ref.read(ordersRepositoryProvider).checkout(selections);
    state = false;

    switch (result) {
      case Success():
        ref.invalidate(buyingOrdersProvider);
        ref.invalidate(cartControllerProvider);
        // TODO: savat provider'ingizni ham yangilang, masalan: ref.invalidate(cartProvider);
      case Error():
        break;
    }
    return result;
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, bool>(CheckoutController.new);
