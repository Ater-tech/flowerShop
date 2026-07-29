import 'package:dio/dio.dart';
import 'package:mobile/models/product_models/banner_model.dart';
import 'package:mobile/server/api_endpoints.dart';

class BannerRepository {
  final Dio dio;

  BannerRepository(this.dio);

  Future<List<BannerModel>> fetchBanners() async {
    final response = await dio.get(ApiEndpoints.banners);
    final data = response.data as List;
    return data
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
} 