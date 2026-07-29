import 'package:dio/dio.dart';
import 'package:mobile/storage/token_storage.dart';
import 'package:mobile/server/api_endpoints.dart';

class TokenRepository {  
  final Dio refreshDio;
  final TokenStorage storage;
  
  TokenRepository({    
    required this.refreshDio, 
    required this.storage});

  // new access token get
  Future<String?> refreshToken() async {
    final refresh = await storage.getRefreshToken();
    if (refresh == null) {
      return null;
    }

    try {
      // api.refresDio new access/
      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {"refresh": refresh},
      );
      final newAccess = response.data["access"];
      await storage.saveAccessToken(newAccess);
      return newAccess;
    } on DioException {
      await storage.deleteTokensAndRememberMe();
      return null;
    }
  }
}