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
    } on DioException catch (e) {
      debugPrint("xatolik: repo: ${e.response?.statusCode}");
      // debugPrint("xatolik: repo: ${e.response?.headers}");
      rethrow;
    }
  }

  Future<void> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await api.post(
        ApiEndpoints.login,
        data: {"username": username, "password": password},
      );
      await storage.saveAccessToken(response.data["access"]);
      await storage.saveRefreshToken(response.data["refresh"]);
      await storage.saveRememberMe(rememberMe);
    } on DioException catch (e) {
      debugPrint("Xatolik: login: ${e.response!.statusCode}");
      // debugPrint("Xatolik: login: ${e.response!.data}");
      rethrow;
    }
  }

  Future<void> logout({
    required String username,
    required String password,
  }) async {
    try {
      await storage.deleteTokensAndRememberMe();
    } catch (e) {
      debugPrint("Xatolik: logout: $e");
      rethrow;
    }
  }

  Future<bool> shouldAutoLogin() async {
    final rememberMe = await storage.getRememberMe();
    if (!rememberMe) return false;

    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await api.post(
        ApiEndpoints.refresh,
        data: {'refresh': refreshToken},
      );
      final newAccess = response.data['access'] as String;
      await storage.saveAccessToken(newAccess);
      return true;
    } catch (_) {
      await storage.deleteTokensAndRememberMe();
      return false;
    }
  }
}
