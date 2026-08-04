// domain/repositories/product_repository.dart
import 'dart:io';

import '../models/product_model.dart';
import 'package:mobile/models/product_models/product_query.dart';
import '../error_handler/error_result.dart'; // sizdagi Result<T> / Failure

abstract class ProductRepository {
  Future<Result<List<ProductModel>>> fetchProducts(ProductQuery query);
  Future<Result<ProductModel>> saveFlower({
    required String name,
    required String description,
    required int cityId,
    required double price,
    required bool available,
    required File image,
    double? oldPrice,
    int discountPercent,
    bool isOriginal,
  });
}
