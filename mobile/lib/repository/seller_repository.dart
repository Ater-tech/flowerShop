import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:mobile/error_handler/dio_failure_mapper.dart";
import "package:mobile/error_handler/error_result.dart";
import "package:mobile/models/seller_model.dart";
import "package:mobile/server/api_endpoints.dart";
abstract class SellerRepository {
  Future<Result<SellerModel?>> getMyProfile();
  Future<Result<SellerModel>> becomeSeller();
}

class SellerRepositoryImpl implements SellerRepository {
  final Dio dio;
  SellerRepositoryImpl({required this.dio});

  @override
  Future<Result<SellerModel?>> getMyProfile() async {
    try {
      final response = await dio.get(ApiEndpoints.sellerMe);
      return Success(SellerModel.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Success(null); // Seller yo'q — bu XATO emas, holat
      }
      return Error(mapDioExceptionToFailure(e));
    }
  }

  @override
  Future<Result<SellerModel>> becomeSeller() async {
    try {
      final response = await dio.post(ApiEndpoints.sellers, data: {});
      return Success(SellerModel.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('BECOME SELLER ERROR: ${e.response?.statusCode} - ${e.response?.data}');
      return Error(mapDioExceptionToFailure(e));
    }
  }
}