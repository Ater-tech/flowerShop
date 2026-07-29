import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/providers/repo_providers.dart';
import 'package:mobile/server/api_endpoints.dart';

/// Token/sessiya borligini tekshiruvchi repository.
/// Haqiqiy loyihada bu yerga SharedPreferences, SecureStorage yoki
/// Django REST API'ga (masalan /api/auth/verify/) so'rov qo'shiladi.
abstract class AuthCheckRepository {
  Future<bool> hasValidSession();
}

class AuthCheckRepositoryImpl implements AuthCheckRepository {
  final Ref ref;
  AuthCheckRepositoryImpl(this.ref);
  @override
  Future<bool> hasValidSession() async {
    // SharedPreferences orqali tokenni o'qish
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('access_token');
    // if (token == null) return false;

    final tokenStorage = ref.read(tokenStorageProvider);
    final rememberMe = await tokenStorage.getRememberMe();
    if(!rememberMe) return false;
    final refreshToken = await tokenStorage.getRefreshToken();
    if(refreshToken == null) return false;

    try{
      final dio = ref.read(apiProvider).dio;
      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {'refresh': refreshToken},
      );
      await tokenStorage.saveAccessToken(response.data['access']);
      return true;
    } catch (_) {
      await tokenStorage.deleteTokensAndRememberMe();
      return false;
    }
    }    
}

/// Repository uchun provider — UI va Controller shu orqali bog'lanadi.
final authCheckRepositoryProvider = Provider<AuthCheckRepository>((ref) {
  return AuthCheckRepositoryImpl(ref);
});