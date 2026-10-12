import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/server/api_endpoints.dart';

import '../error_handler/orders_deps.dart';
import '../models/data/order_enums.dart';
import '../models/data/order_model.dart';

/// Yo'llar bitta joyda: baseUrl'ingizga qarab faqat shu yerni moslang.
class OrdersApi {
  static const base = ApiEndpoints.orders;
  static const meta = '${base}meta/';
  static const selling = '${base}selling/';
  static const checkout = '${base}checkout/'; // urls.py dagi haqiqiy manzilga moslang
  static String action(int id, OrderAction a) => '$base$id/actions/${a.value}/';
}

class OrdersRepository {
  OrdersRepository(this._dio);
  final Dio _dio;

  /// Sahifalash yoqilgan bo'lsa ({results: [...]}) ham, oddiy ro'yxat ham ishlaydi.
  List<Map<String, dynamic>> _list(Object? raw) {
    final list = raw is Map ? raw['results'] : raw;
    return (list as List).cast<Map<String, dynamic>>();
  }

  Future<Result<OrdersMeta>> fetchMeta() => guardRequest(() async {
        final res = await _dio.get(OrdersApi.meta);
        return OrdersMeta.fromJson(res.data as Map<String, dynamic>);
      });

  Future<Result<List<OrderModel>>> fetchOrders(OrderRole role, {int? productId}) =>
      guardRequest(() async {
        final res = role == OrderRole.buying
            ? await _dio.get(OrdersApi.base)
            : await _dio.get(
                OrdersApi.selling,
                queryParameters: {'product': ?productId},
              );
        return _list(res.data).map(OrderModel.fromJson).toList();
      });

  Future<Result<OrderModel>> performAction(int orderId, OrderAction action) =>
      guardRequest(() async {
        final res = await _dio.post(OrdersApi.action(orderId, action));
        return OrderModel.fromJson(res.data as Map<String, dynamic>);
      });

  Future<Result<List<OrderModel>>> checkout(List<ShopSelection> selections) =>
      guardRequest(() async {
        final res = await _dio.post(
          OrdersApi.checkout,
          data: {'orders': selections.map((s) => s.toJson()).toList()},
        );
        return _list(res.data).map(OrderModel.fromJson).toList();
      });
}

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(ref.watch(apiProvider).dio),
);
