import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints { 
  static String baseUrl = dotenv.env["FLOWER_URL"]!; 
  static const flowers = "/api/flowers/";
  static const login = "/api/token/";
  static const refresh = "/api/token/refresh/";
  static const register = "/api/register/";
  static const deleteAccount = "/api/token/delete/";
  static const getUserProfile = "/api/user/";
  static const updateUserProfile = "/api/user/";
  static const citiesList = "/api/cities/";
  static const userCity = "/api/user/city/";
  
}
