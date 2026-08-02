// domain/repositories/product_repository.dart
import '../models/product_model.dart';
import 'package:mobile/models/product_models/product_query.dart';
import '../error_handler/error_result.dart'; // sizdagi Result<T> / Failure

abstract class ProductRepository {
  Future<Result<List<ProductModel>>> fetchProducts(ProductQuery query);
}
