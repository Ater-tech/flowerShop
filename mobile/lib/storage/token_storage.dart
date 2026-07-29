import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  const TokenStorage();
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _rememberMeKey = 'rememberMe';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  
  //save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }
  
  //save refresh token
  Future<void> saveRefreshToken(String token) async{
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey); 
  }

  // get access token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // delete tokens
  Future<void> deleteTokensAndRememberMe() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
     final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
  }

  // rememberMe flag
  Future<void> saveRememberMe(bool value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}