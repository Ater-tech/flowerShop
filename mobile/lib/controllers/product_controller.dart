import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/providers/product_repo_providers.dart';

class ProductController extends AsyncNotifier<List<ProductModel>> {

  @override
  Future<Result<List<ProductModel>>> build() async {
    final repo = ref.read(productRepositoryProvider);

    return repo.fetchProducts();
  }

  Future<void> delete(int id) async {
    final repo = ref.read(productRepositoryProvider);

    await repo.deleteProduct(id);
  }

  Future<void> add(...) async {
    final repo = ref.read(productRepositoryProvider);

    await repo.addProduct(...);
  }
}