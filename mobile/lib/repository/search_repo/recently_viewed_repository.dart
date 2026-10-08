import 'package:flutter/material.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/error_handler/failure.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/storage/recently_viewed_local_ds.dart';

abstract class RecentlyViewedRepository {
  Future<Result<List<ProductModel>>> getAll();
  Future<Result<List<ProductModel>>> add(ProductModel product);
  Future<Result<List<ProductModel>>> clear();
}

class RecentlyViewedRepositoryImpl implements RecentlyViewedRepository {
  RecentlyViewedRepositoryImpl(this._ds);
  final RecentlyViewedLocalDataSource _ds;

  @override
  Future<Result<List<ProductModel>>> getAll() => _guard(_ds.read);

  @override
  Future<Result<List<ProductModel>>> add(ProductModel product) => _guard(() async {
        final items = await _ds.read()
          ..removeWhere((p) => p.id == product.id) // dublikatsiz
          ..insert(0, product);                    // eng yangisi birinchi
        final trimmed = items.take(RecentlyViewedLocalDataSource.maxItems).toList();
        await _ds.write(trimmed);
        return trimmed;
      });

  @override
  Future<Result<List<ProductModel>>> clear() => _guard(() async {
        await _ds.write(const []);
        return <ProductModel>[];
      });

  Future<Result<List<ProductModel>>> _guard(
      Future<List<ProductModel>> Function() action) async {
    try {
      return Success(await action());
    } catch (e, st) {
      debugPrint('[recent] ERROR: $e\n$st');
      return Error<List<ProductModel>>(const CacheFailure());
    }
  }
}