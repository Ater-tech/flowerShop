import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/token_model.dart';
import 'package:mobile/server/api_main_service.dart';
import 'api_endpoints.dart';

class UserApiService {
  final ApiMainService apiService;

  UserApiService(this.apiService);

  Future<TokenModel?> login(String username, String password) async {
    try {
      final response = await apiService.dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      return TokenModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Status ${e.response?.statusCode}");
      // debugPrint("Body ${e.response?.data}");
      rethrow;
    }
  }
}
