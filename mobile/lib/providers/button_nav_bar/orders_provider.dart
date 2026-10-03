import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/product_model.dart';

import 'package:mobile/repository/button_nav_bar/order_remote_ds.dart';
import 'package:mobile/repository/button_nav_bar/order_repository_imp.dart';
import 'package:mobile/repository/button_nav_bar/order_repository.dart';
import '/models/button_nav_bar/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    OrderRemoteDataSource(ref.watch(apiProvider).dio), 
  );
});

final myOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  return switch (await ref.watch(orderRepositoryProvider).getMyOrders()) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

final myProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  return switch (await ref.watch(orderRepositoryProvider).getMyProducts()) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});