import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/flower_model.dart';

class FlowerApiServer {
  static Future<List<FlowerModel>> getData() async {
    final flowerUrl = dotenv.env["FLOWER_URL"];
    try {
      Dio dio = Dio();
      final resp = await dio.get(flowerUrl!);
      // debugPrint(resp.data.toString());
      return (resp.data as List).map((e) => FlowerModel.fromJSON(e)).toList();
    } on DioException catch (e) {
      debugPrint("${e.toString()} Dio error");
      return [];
    }
  }
}
