import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/models/product_model.dart';
import 'api_endpoints.dart';
import 'api_main_service.dart';

class FlowerApiServer {
  ApiMainService service;

  FlowerApiServer(this.service);

  // getData()
  Future<List<ProductModel>> getData() async {
    try {
      Response resp = await service.dio.get(ApiEndpoints.flowers);
      return (resp.data as List).map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception("FLower status: $e.response?.statusCode");
    }
  }

  // Save
  Future<void> saveFlower({
    required String name,
    required String shopName,
    required String description,
    required String location,
    required double price,
    required bool available,
    required File image,
    required bool isFav,
  }) async {
    debugPrint("save_flower()chaqirildi");
    try {
      final formData = FormData.fromMap({
        'name': name,
        // 'shop_name': shopName,
        'image': await MultipartFile.fromFile(image.path),
        'description': description,
        'city': cityId,
        // 'shopAsistense': [],
        'price': price,
        'available': available,
        'is_favourite': isFav,
      });
      await service.dio.post(ApiEndpoints.flowers, data: formData);
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("Statusssssssssssss ${e.response!.statusCode}");
        debugPrint("Dataaaaaaaa ${e.response!.data}");
      } else {
        debugPrint("Network Errorrrrrr: ${e.message}");
      }
      rethrow;
    } catch (e) {
      debugPrint("Unknown Error: $e");
      rethrow;
    }
  }
}
