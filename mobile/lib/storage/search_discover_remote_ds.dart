import 'package:dio/dio.dart';

class SearchDiscoverRemoteDataSource {
  SearchDiscoverRemoteDataSource(this._dio);
  final Dio _dio;

  // TODO: backend URL'lariga moslang
  static const recommendedPath = 'products/discover/recommended/';
  static const popularPath = 'products/discover/popular/';

  Future<List<Map<String, dynamic>>> fetch(String path, {required int limit}) async {
    final res = await _dio.get<dynamic>(path, queryParameters: {'limit': limit});
    final data = res.data;
    // Paginatsiyali ({results: [...]}) ham, oddiy ro'yxat ham ishlaydi.
    final list = (data is Map ? data['results'] : data) as List;
    return list.cast<Map<String, dynamic>>();
  }
}
