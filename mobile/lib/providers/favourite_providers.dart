// favourites/application/favourite_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/providers/repo_providers.dart';
import 'product_search_providers.dart';
// import '../../../core/network/api_main_service_provider.dart';

/// Hozirda qaysi mahsulot ID'lari uchun so'rov ketayotganini ushlab turadi
final favouritePendingIdsProvider = StateProvider<Set<int>>((ref) => {});

class FavouriteController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(int productId) async {
    final pendingIds = ref.read(favouritePendingIdsProvider.notifier);

    // Bir xil mahsulotga qayta-qayta bosishning oldini olamiz
    if (ref.read(favouritePendingIdsProvider).contains(productId)) return;

    pendingIds.update((state) => {...state, productId});

    try {
      final apiService = ref.read(apiProvider);
      await apiService.dio.post(
        "/api/favourites/toggle/",
        data: {"flower": productId},
      );

      // Server javobi kelgach, ro'yxatni serverdan qayta so'raymiz
      ref.invalidate(productListProvider);
      await ref.read(productListProvider.future);
    } finally {
      pendingIds.update((state) => {...state}..remove(productId));
    }
  }
}

final favouriteControllerProvider = NotifierProvider<FavouriteController, void>(
  FavouriteController.new,
);
