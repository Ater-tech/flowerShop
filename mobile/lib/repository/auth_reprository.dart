import 'package:dio/dio.dart';
import 'package:mobile/repository/token_storage.dart';
import 'package:mobile/server/api_endpoints.dart';

class AuthReprository {
  final Dio refreshDio;
  final TokenStorage storage;

  AuthReprository({required this.refreshDio, required this.storage});

  Future<String?> refreshToken() async {
    final refresh = await storage.getRefreshToken();
    if (refresh == null) {
      return null;
    }

    try {
      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {"refresh": refresh},
      );
      final newAccess = response.data["access"];
      await storage.saveAccessToken(newAccess);
      return newAccess;
    } on DioException {
      await storage.deleteTokens();
      return null;
    }
  }
}
