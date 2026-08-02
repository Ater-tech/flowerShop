// application/product_repository_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/repo_providers.dart';
import '../repository/product_repository_impl.dart';
import '../repository/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiService = ref.watch(apiProvider);
  return ProductRepositoryImpl(apiService.dio);
});
