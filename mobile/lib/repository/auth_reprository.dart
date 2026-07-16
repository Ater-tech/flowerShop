import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/storage/token_storage.dart';
import 'package:mobile/server/api_endpoints.dart';

class AuthReprository {
  final Dio api;
  final TokenStorage storage;

  AuthReprository({required this.api, required this.storage});

  Future<void> register({
    required String username,
    required String password,
  }) async {
    try {
      // final response = 
      await api.post(
        ApiEndpoints.register,
        data: {"username": username, "password": password},
      );
    } on DioException catch(e) {
      debugPrint("xatolik: repo: ${e.response?.statusCode}");
      debugPrint("xatolik: repo: ${e.response?.data}");
      rethrow;
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async{
    try {
      final response = await api.post(
        ApiEndpoints.login,
        data: {"username": username, "password": password},
      );
      await storage.saveAccessToken(response.data["access"]);
      await storage.saveRefreshToken(response.data["refresh"]);
    } on DioException catch(e){
      debugPrint("Xatolik: login: $e");
      rethrow;
    }    
  }
  Future<void> logout({
    required String username,
    required String password,
  }) async{
    try {      
      await storage.deleteTokens();
    } catch(e){
      debugPrint("Xatolik: login: $e");
      rethrow;
    }    
  }

}
