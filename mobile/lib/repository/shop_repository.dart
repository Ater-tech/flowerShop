import "package:dio/dio.dart";
import "package:mobile/error_handler/dio_failure_mapper.dart";
import "package:mobile/server/api_endpoints.dart";

import "../models/shop_model.dart";
import "../error_handler/error_result.dart";

abstract class ShopRepository {
  Future<Result<List<ShopModel>>> getMyShops();
  Future<Result<ShopModel>> createShop(ShopModel shop);
  Future<Result<void>> setDefault(int shopId);
}

class ShopRepositoryImpl implements ShopRepository {
  final Dio api;
  ShopRepositoryImpl({required this.api});

  @override
  Future<Result<List<ShopModel>>> getMyShops() async {
    try {
      final response = await api.get(ApiEndpoints.shops);
      final shops = (response.data as List)
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(shops);
    } on DioException catch (e) {
      return Error(mapDioExceptionToFailure(e));
    }
  }

  @override
  Future<Result<ShopModel>> createShop(ShopModel shop) async {
    try {
      final response = await api.post(ApiEndpoints.shops, data: shop.toJson());
      return Success(ShopModel.fromJson(response.data));
    } on DioException catch (e) {
      // debugPrint('ERROR RESPONSE: ${e.response?.data}');  // ← vaqtinchalik
      return Error(mapDioExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> setDefault(int shopId) async {
    try {
      await api.post('${ApiEndpoints.shops}$shopId/set_default/');
      return const Success(null);
    } on DioException catch (e) {
      return Error(mapDioExceptionToFailure(e));
    }
  }
}