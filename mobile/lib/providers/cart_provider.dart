import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/error_handler/error_result.dart';

import 'package:mobile/repository/cart_item/cart_remote_ds.dart';
import 'package:mobile/repository/cart_item/cart_repository_impl.dart';
import 'package:mobile/repository/cart_item/cart_repository.dart';
import '../models/cart_item_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    CartRemoteDataSource(ref.watch(apiProvider).dio),
  );
});

/// Savat ro'yxati + mutatsiyalar (qo'shish/o'zgartirish/o'chirish) shu
/// controller orqali boshqariladi — har mutatsiyadan keyin ro'yxat
/// serverdan qayta o'qiladi, shuning uchun narx/qoldiq doim aniq bo'ladi.
class CartController extends AsyncNotifier<List<CartItemModel>> {
  CartRepository get _repo => ref.read(cartRepositoryProvider);

  @override
  Future<List<CartItemModel>> build() async {
    return switch (await _repo.getCartItems()) {
      Success(:final data) => data,
      Error() => const <CartItemModel>[],
    };
  }

  Future<void> addProduct(int productId, {int quantity = 1}) async {
    if (await _repo.addProduct(productId, quantity) case Success()) {
      await _reload();
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    if (await _repo.updateQuantity(itemId, quantity) case Success()) {
      await _reload();
    }
  }

  Future<void> removeItem(int itemId) async {
    if (await _repo.removeItem(itemId) case Success()) {
      await _reload();
    }
  }

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final cartControllerProvider =
    AsyncNotifierProvider<CartController, List<CartItemModel>>(CartController.new);

/// Umumiy narx — har bir qator narxi * soni yig'indisi.
final cartTotalProvider = Provider.autoDispose<double>((ref) {
  final items = ref.watch(cartControllerProvider).value ?? const [];
  return items.fold<double>(0, (sum, item) => sum + item.lineTotal);
});