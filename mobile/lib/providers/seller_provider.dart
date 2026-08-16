import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/seller_model.dart';
import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/repository/seller_repository.dart';

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  return ref.watch(apiProvider).sellerRepositoryImpl;
});

final sellerProfileProvider = FutureProvider.autoDispose<SellerModel?>((ref) async {
  final result = await ref.watch(sellerRepositoryProvider).getMyProfile();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});