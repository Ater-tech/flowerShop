// application/product_search_providers.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/product_models/product_query.dart';
import '../error_handler/error_result.dart';
import 'product_repo_providers.dart';

/// Foydalanuvchi TextField'ga yozgan xom matn (har harfda o'zgaradi)
final rawSearchInputProvider = StateProvider<String>((ref) => "");

/// Filter/sort holati (city, ordering, premium)
final productQueryProvider = StateProvider<ProductQuery>((ref) {
  return const ProductQuery();
});

/// Debounce qilingan qidiruv — 400ms kutadi, keyin haqiqiy query'ga yozadi
final debouncedSearchProvider = StateProvider<String>((ref) => "");

class SearchDebouncer extends Notifier<void> {
  Timer? _timer;

  @override
  void build() {
    ref.listen(rawSearchInputProvider, (previous, next) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 400), () {
        ref.read(debouncedSearchProvider.notifier).state = next;
      });
    });
  }
}

final searchDebouncerProvider = NotifierProvider<SearchDebouncer, void>(
  SearchDebouncer.new,
);

/// Yakuniy query — debounce qilingan search + filter/sort birlashadi
final effectiveQueryProvider = Provider<ProductQuery>((ref) {
  ref.watch(
    searchDebouncerProvider,
  ); // debouncer ishga tushishi uchun watch qilamiz
  final search = ref.watch(debouncedSearchProvider);
  final baseQuery = ref.watch(productQueryProvider);
  return baseQuery.copyWith(search: search);
});

/// Asosiy mahsulotlar ro'yxati — effectiveQuery o'zgarganda avtomatik qayta so'rov yuboradi
final productListProvider = FutureProvider.autoDispose<List<ProductModel>>((
  ref,
) async {
  final query = ref.watch(effectiveQueryProvider);
  final repository = ref.watch(productRepositoryProvider);

  final result = await repository.fetchProducts(query);

  return result.when(
    success: (products) => products,
    error: (failure) => throw failure,
  );
});
