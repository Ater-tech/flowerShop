import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/providers/repo_providers.dart'; // apiProvider
import 'package:mobile/error_handler/error_result.dart'; 
import 'package:mobile/storage/search_discover_remote_ds.dart';
import 'package:mobile/storage/search_history_local_ds.dart';
import 'package:mobile/repository/search_discover_repository_impl.dart';
import 'package:mobile/repository/search_history_repository_impl.dart';
import 'package:mobile/repository/search_discover_repository.dart';
import 'package:mobile/repository/search_history_repository.dart';
import 'package:mobile/models/product_model.dart';

// ───────── Tab holati ─────────
enum SearchTab { recent, recommended, popular }

final searchTabProvider = StateProvider<SearchTab>((_) => SearchTab.recent);

// ───────── Qidiruv tarixi ─────────
final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>(
  (ref) => SearchHistoryRepositoryImpl(SearchHistoryLocalDataSource()),
);

class SearchHistoryController extends AsyncNotifier<List<String>> {
  SearchHistoryRepository get _repo => ref.read(searchHistoryRepositoryProvider);

  @override
  Future<List<String>> build() async {
    return switch (await _repo.getHistory()) {
      Success(:final data) => data,
      Error() => const <String>[],
    };
  }

  Future<void> add(String query) => _apply(() => _repo.add(query));
  Future<void> remove(String query) => _apply(() => _repo.remove(query));
  Future<void> clear() => _apply(_repo.clear);

  Future<void> _apply(Future<Result<List<String>>> Function() op) async {
    if (await op() case Success(:final data)) state = AsyncData(data);
  }
}

final searchHistoryControllerProvider =
    AsyncNotifierProvider<SearchHistoryController, List<String>>(SearchHistoryController.new);

// ───────── Tavsiya va mashhurlar ─────────
final searchDiscoverRepositoryProvider = Provider<SearchDiscoverRepository>(
  (ref) => SearchDiscoverRepositoryImpl(
    SearchDiscoverRemoteDataSource(ref.watch(apiProvider).dio), // turi Dio 
  ),
);

// Tab almashganda qayta yuklanmasligi uchun 2 daqiqa saqlaydi.
extension _CacheFor on Ref {
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }
}

final recommendedProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  debugPrint('[discover] recommended BUILD');
   ref.onDispose(() => debugPrint('[discover] recommended DISPOSE'));
  ref.cacheFor(const Duration(minutes: 2));
  return switch (await ref.watch(searchDiscoverRepositoryProvider).getRecommended()) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

final popularProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  ref.cacheFor(const Duration(minutes: 2));
  return switch (await ref.watch(searchDiscoverRepositoryProvider).getPopular()) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});