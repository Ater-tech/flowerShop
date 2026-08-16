import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints { 
  static String baseUrl = dotenv.env["FLOWER_URL"]!; 
  static const flowers = "/api/flowers/";
  static const login = "/api/auth/token/";
  static const refresh = "/api/auth/token/refresh/";
  static const register = "/api/auth/register/";
  static const deleteAccount = "/api/token/delete/";
  static const getUserProfile = "/api/user/";
  static const updateUserProfile = "/api/user/";
  static const citiesList = "/api/cities/";
  static const userCity = "/api/user/city/";
  static const banners = "/api/banners/";
  static const shops = "/api/shops/";
  
}
