import 'package:dio/dio.dart';
import 'package:mobile/server/api_endpoints.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._dio);
  final Dio _dio;

  static const myOrdersPath = ApiEndpoints.myOrdersPath;
  static const myProductsPath = ApiEndpoints.myProductsPath;
  static const checkoutPath = ApiEndpoints.checkoutPath;

  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    final res = await _dio.get<dynamic>(path);
    final data = res.data;
    if (data == null) return const [];
    final list = (data is Map ? data['results'] : data) as List? ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> checkout() async{
    final res = await _dio.post<dynamic>(checkoutPath);
    final data = res.data;
    final list = (data is List ? data : const []);
    return list.cast<Map<String, dynamic>>();
  }
  Future<List<Map<String, dynamic>>> fetchMyOrders() => _fetchList(myOrdersPath);
  Future<List<Map<String, dynamic>>> fetchMyProducts() => _fetchList(myProductsPath);
}