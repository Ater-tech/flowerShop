import 'package:dio/dio.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._dio);
  final Dio _dio;

  static const basePath = 'cart/items/';

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final res = await _dio.get<dynamic>(basePath);
    final data = res.data;
    if (data == null) return const [];
    final list = (data is Map ? data['results'] : data) as List? ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> addProduct(int productId, int quantity) async {
    final res = await _dio.post<dynamic>(
      basePath,
      data: {'product': productId, 'quantity': quantity},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateQuantity(int itemId, int quantity) async {
    final res = await _dio.patch<dynamic>(
      '$basePath$itemId/',
      data: {'quantity': quantity},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<void> removeItem(int itemId) async {
    await _dio.delete<void>('$basePath$itemId/');
  }
}