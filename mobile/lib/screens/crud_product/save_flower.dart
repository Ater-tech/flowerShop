import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FlowerWriteRepository {
  final Dio dio = Dio(BaseOptions(baseUrl: dotenv.env["FLOWER_URL"] ?? ""));
  Future<void> saveFlower({
    required String name,
    required String shopName,
    required String description,
    required String location,
    required double price,
    required bool aviable,
    required File image,
  }) async {
    debugPrint("chaqirildi");
    try {
      final formData = FormData.fromMap({
        'name': name,
        'shop_name': shopName,
        'image': await MultipartFile.fromFile(image.path),
        'description': description,
        'location': location,
        // 'shopAsistense': [],
        'price': price,
        'aviable': aviable,
      });
      await dio.post('/', data: formData);
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
