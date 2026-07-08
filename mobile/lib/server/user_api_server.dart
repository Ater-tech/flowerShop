import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_endpoints.dart';

class UserApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['FLOWER_URL']!,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );
  Future<String?> login(String username, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      return response.data['access'];
    } on DioException catch (e) {
      debugPrint("Status ${e.response?.statusCode}");
      debugPrint("Body ${e.response?.data}");
      return null;
    }
  }
}
