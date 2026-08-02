import 'package:dio/dio.dart';
import 'package:mobile/error_handler/failure.dart';
import '../models/product_model.dart';
import '../models/product_models/product_query.dart';
import '../repository/product_repository.dart';
import '../error_handler/error_result.dart';
import '../error_handler/dio_failure_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Dio dio;

  ProductRepositoryImpl(this.dio);

  @override
  Future<Result<List<ProductModel>>> fetchProducts(ProductQuery query) async {
    try {
      final response = await dio.get(
        "/api/flowers/",
        queryParameters: query.toQueryParams(),
      );

      final results = response.data is Map
          ? response.data["results"] as List
          : response.data as List;

      final products = results
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(products);
    } on DioException catch (e) {
      return Error(mapDioExceptionToFailure(e));
    } catch (e) {
      return const Error(UnknownFailure());
    }
  }
}
