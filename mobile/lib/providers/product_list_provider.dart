// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/error_handler/error_result.dart';
// import 'package:mobile/models/product_model.dart';
// import 'package:mobile/models/product_models/product_query.dart';
// import 'package:mobile/providers/product_repo_providers.dart';

// final productListProvider = FutureProvider.autoDispose
//     .family<List<ProductModel>, ProductQuery>((ref, query) async {
//   // autoDispose + keepAlive(cacheTime) — foydalanuvchi sahifadan
//   // chiqib qaytib kelsa qayta so'rov yubormasdan turadi
//   final link = ref.keepAlive();
//   Timer(const Duration(minutes: 5), () => link.close());

//   final repo = ref.watch(productRepositoryProvider);
//   final result = await repo.fetchProducts(query);

//   return switch (result) {
//     Success(:final data) => data,
//     Error(:final failure) => throw failure,
//   };
// });