import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage();
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  //save access token
  Future<void> saveAccessToken(String token) async {
    await storage.write(key: _accessTokenKey, value: token);
  }
  
  //save refresh token
  Future<void> saveRefreshToken(String token) async{
    await storage.write(key: _refreshTokenKey, value: token);
  }

  // get access token
  Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey); 
  }

  // get access token
  Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }
  
  // delete tokens
  Future<void> deleteTokens() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }
}