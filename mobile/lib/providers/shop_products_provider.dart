import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/models/product_models/product_query.dart';
import 'package:mobile/providers/product_repo_providers.dart';

final shopProductsProvider = FutureProvider.autoDispose
    .family<List<ProductModel>, int>((ref, shopId) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.fetchProducts(
    ProductQuery(shopId: shopId, ordering: '-created_at'),
  );

  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});