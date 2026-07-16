import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/storage/token_storage.dart';

/// Token/sessiya borligini tekshiruvchi repository.
/// Haqiqiy loyihada bu yerga SharedPreferences, SecureStorage yoki
/// Django REST API'ga (masalan /api/auth/verify/) so'rov qo'shiladi.
abstract class AuthCheckRepository {
  Future<bool> hasValidSession();
}

class AuthCheckRepositoryImpl implements AuthCheckRepository {
  final storage = TokenStorage();
  @override
  Future<bool> hasValidSession() async {
    // SharedPreferences orqali tokenni o'qish
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('access_token');
    // if (token == null) return false;
    final token = await storage.getAccessToken();
    if(token == null) return false;

    await Future.delayed(const Duration(milliseconds: 200));
    return false;
  }
}

/// Repository uchun provider — UI va Controller shu orqali bog'lanadi.
final authCheckRepositoryProvider = Provider<AuthCheckRepository>((ref) {
  return AuthCheckRepositoryImpl();
});