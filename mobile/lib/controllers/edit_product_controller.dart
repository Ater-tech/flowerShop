// edit_product_controller.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/error_handler/failure.dart';
import 'package:mobile/providers/button_nav_bar/orders_provider.dart';
import 'package:mobile/providers/product_provider/product_detail_provider.dart';
import 'package:mobile/providers/product_provider/product_repo_providers.dart';
import 'package:mobile/providers/product_provider/product_search_providers.dart';

class EditProductState {
  final bool isSaving;
  final bool isDeleting;
  const EditProductState({this.isSaving = false, this.isDeleting = false});
  bool get isBusy => isSaving || isDeleting;
  EditProductState copyWith({bool? isSaving, bool? isDeleting}) =>
      EditProductState(
        isSaving: isSaving ?? this.isSaving,
        isDeleting: isDeleting ?? this.isDeleting,
      );
}

class EditProductController extends Notifier<EditProductState> {
  @override
  EditProductState build() => const EditProductState();

  Future<Failure?> save({
    required int id,
    required String name,
    required num price,
    required String description,
    File? newImage,
  }) async {
    state = state.copyWith(isSaving: true);
    final result = await ref
        .read(productRepositoryProvider)
        .updateProduct(
          id: id,
          name: name,
          price: price,
          description: description,
          newImage: newImage,
        );
    state = state.copyWith(isSaving: false);

    return switch (result) {
      Success() => _refresh(id),
      Error(:final failure) => failure,
    };
  }

  Future<Failure?> delete(int id) async {
    state = state.copyWith(isDeleting: true);
    final result = await ref.read(productRepositoryProvider).deleteProduct(id);
    state = state.copyWith(isDeleting: false);

    return switch (result) {
      Success() => _refresh(id),
      Error(:final failure) => failure,
    };
  }

  Failure? _refresh(int id) {
    ref.invalidate(myProductsProvider);
    ref.invalidate(productListProvider);
    ref.invalidate(productDetailProvider(id));
    return null;
  }
}

final editProductControllerProvider =
    NotifierProvider.autoDispose<EditProductController, EditProductState>(
      EditProductController.new,
    );
