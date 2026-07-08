import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/flower_model.dart';
import 'api_endpoints.dart';

class FlowerApiServer {
  static Future<List<FlowerModel>> getData() async {
    try {
      Dio dio = Dio(
        BaseOptions(baseUrl: dotenv.env["FLOWER_URL"]!),
      );
      final resp = await dio.get(
        ApiEndpoints.flowers
      );
      // debugPrint(resp.data.toString());
      return (resp.data as List).map((e) => FlowerModel.fromJSON(e)).toList();
    } on DioException catch (e) {
      debugPrint("${e.toString()} Dio error");
      return [];
    }
  }
}
