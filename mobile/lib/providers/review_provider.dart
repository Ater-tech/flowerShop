// application/review_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/review_model.dart';
import 'package:mobile/providers/repo_providers.dart';

final productReviewsProvider = FutureProvider.autoDispose
    .family<List<Review>, int>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  final result = await repo.fetchProductReviews(productId);

  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});