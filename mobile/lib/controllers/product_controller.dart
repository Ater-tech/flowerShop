import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:mobile/error_handler/error_result.dart';
// import 'package:mobile/error_handler/failure.dart';
import 'package:mobile/models/product_model.dart';
// import 'package:mobile/models/product_models/product_query.dart';
import 'package:mobile/providers/product_repo_providers.dart';
import 'package:mobile/providers/product_search_providers.dart'; // effectiveQueryProvider

class ProductController extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    final repo = ref.read(productRepositoryProvider);
    final query = ref.watch(effectiveQueryProvider); // sizdagi mavjud query provider

    final result = await repo.fetchProducts(query);

    return switch (result) {
      Success(:final data) => data,
      Error(:final failure) => throw failure, // AsyncNotifier buni AsyncError qiladi
    };
  }

  Future<void> add({
    required String name,
    required String description,
    required int cityId,
    required double price,
    required bool available,
    required File image,
    double? oldPrice,
    int discountPercent = 0,
    bool isOriginal = false,
  }) async {
    final repo = ref.read(productRepositoryProvider);

    final result = await repo.saveFlower(
      name: name,
      description: description,
      cityId: cityId,
      price: price,
      available: available,
      image: image,
      oldPrice: oldPrice,
      discountPercent: discountPercent,
      isOriginal: isOriginal,
    );

    switch (result) {
      case Success():
        ref.invalidateSelf(); // ro'yxatni qayta yuklaydi
      case Error(:final failure):
        state = AsyncError(failure, StackTrace.current);
    }
  }
}

final productControllerProvider =
    AsyncNotifierProvider<ProductController, List<ProductModel>>(
  ProductController.new,
);