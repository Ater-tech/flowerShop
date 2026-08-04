import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile/error_handler/failure.dart';
import 'package:mobile/server/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/product_models/product_query.dart';
import '../repository/product_repository.dart';
import '../error_handler/error_result.dart';
import '../error_handler/dio_failure_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Dio dio;

  ProductRepositoryImpl({required this.dio});

  @override
  Future<Result<List<ProductModel>>> fetchProducts(ProductQuery query) async {
    try {
      final response = await dio.get(
        ApiEndpoints.flowers,
        queryParameters: query.toQueryParams(),
      );

      final results = response.data is Map
          ? response.data["results"]
                as List //pagnitation bo'lsa
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

  @override
  Future<Result<ProductModel>> saveFlower({
    required String name,
    required String description,
    required int cityId,
    required double price,
    required bool available,
    required File image,
    double? oldPrice,
    int discountPercent = 0,
    bool isOriginal = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'city': cityId,
        'price': price.toStringAsFixed(3),
        if (oldPrice != null) 'old_price': oldPrice.toStringAsFixed(2),
        'discount_percent': discountPercent,
        'available': available,
        'is_original': isOriginal,
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await dio.post(ApiEndpoints.flowers, data: formData);

      return Success(ProductModel.fromJson(response.data));
    } on DioException catch (e) {
      // 402 — maxsus holat: limit tugagan, paywall ko'rsatish kerak
      if (e.response?.statusCode == 402) {
        final data = e.response?.data as Map<String, dynamic>?;
        return Error(
          PaymentRequiredFailure(
            message: data?['message'] ?? "Limit tugadi",
            options: (data?['options'] as List?)?.cast<String>() ?? [],
            pricePerProduct: data?['price_per_product'] ?? 5000,
          ),
        );
      }

      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          return Error(ValidationFailure(data));
        }
        return Error(mapDioExceptionToFailure(e));
      }

      return Error(mapDioExceptionToFailure(e));
    } catch (e) {
      return const Error(UnknownFailure());
    }
  }
}
