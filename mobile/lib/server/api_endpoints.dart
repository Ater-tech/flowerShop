import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints { 
  static String baseUrl = dotenv.env["FLOWER_URL"]!; 
  static const flowers = "/api/flowers/";
  static const login = "/api/token/";
  static const refresh = "/api/token/refresh/";
  static const register = "/api/token/register/";
}
