import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/providers/product_repo_providers.dart';

final productDetailProvider = FutureProvider.autoDispose
    .family<ProductModel, int>((ref, productId) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.fetchProductDetail(productId);
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});