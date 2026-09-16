
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/models/product_models/product_query.dart';
import 'package:mobile/providers/product_repo_providers.dart';

final recommendedProductsProvider = FutureProvider.autoDispose
    .family<List<ProductModel>, int>((ref, excludeProductId) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.fetchProducts(
    ProductQuery(
      excludeId: excludeProductId,
      ordering: '-recommendation_score',
    ),
  );

  return switch (result) {
    Success(data: final products) => products,
    Error(failure: final f) => throw f,
  };
});