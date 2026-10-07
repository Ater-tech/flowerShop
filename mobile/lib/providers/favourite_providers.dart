// favourites/application/favourite_providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/providers/product_provider/product_detail_provider.dart';
import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/server/api_endpoints.dart';
import 'product_provider/product_search_providers.dart';
import 'package:mobile/models/flower_model.dart';

/// Hozirda qaysi mahsulot ID'lari uchun so'rov ketayotganini ushlab turadi
final favouritePendingIdsProvider = StateProvider<Set<int>>((ref) => {});

final favouritesListProvider = FutureProvider.autoDispose<List<FlowerModel>>((
  ref,
) async {
  final api = ref.watch(apiProvider);
  final res = await api.dio.get(ApiEndpoints.favList);

  // pagination yoqilgan bo'lsa {results: [...]}, bo'lmasa oddiy list
  final raw = res.data;
  final list = (raw is Map ? raw['results'] : raw) as List;

  return list
      .map(
        (e) => FlowerModel.fromJSON(e['flower_detail'] as Map<String, dynamic>),
      )
      .toList();
});

class FavouriteController extends Notifier<void> {
  @override
  void build() {}

  Future<bool> toggle(int productId) async {
  final pendingIds = ref.read(favouritePendingIdsProvider.notifier);
  if (ref.read(favouritePendingIdsProvider).contains(productId)) return false;
  pendingIds.update((s) => {...s, productId});
  try {
    await ref.read(apiProvider).dio.post(
      ApiEndpoints.favToggle,
      data: {"flower": productId},
    );
    ref.invalidate(productListProvider);
    ref.invalidate(favouritesListProvider);
    ref.invalidate(productDetailProvider(productId));
    return true;
  } on DioException {
    return false; // UI'da SnackBar ko'rsatish mumkin
  } finally {
    pendingIds.update((s) => {...s}..remove(productId));
  }
}
}

final favouriteControllerProvider = NotifierProvider<FavouriteController, void>(
  FavouriteController.new,
);
