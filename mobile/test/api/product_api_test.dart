import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;

  const baseUrl =
      'https://flowershop-production-4e9b.up.railway.app/';

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  });

  
  test('POST /api/flowers/ - create product', () async {
    final loginResponse = await dio.post(
  '/api/auth/token/',
  data: {
    'username': 'ater2',
    'password': '1234',
  },
);

  final accessToken = loginResponse.data['access'];

    final image = File('test/assets/appbar.png');

    final formData = FormData.fromMap({
      'name': 'Test Rose',
      'description': 'API integration test product',
      'shop': 2,
      'price': '25000.000',
      'discount_percent': 0,
      'available': true,
      'is_original': false,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: 'test_flower.jpg',
      ),
    });

    try {
      final response = await dio.post(
        '/api/flowers/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('DATA: ${response.data}');

      expect(response.statusCode, 201);
    } on DioException catch (e) {
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('DATA: ${e.response?.data}');
      debugPrint('MESSAGE: ${e.message}');

      fail(
        'API request failed: '
        '${e.response?.statusCode} ${e.response?.data}',
      );
    }
  });
}