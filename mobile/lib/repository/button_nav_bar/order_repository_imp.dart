import 'package:dio/dio.dart';
import 'package:mobile/error_handler/failure.dart';
import 'package:mobile/error_handler/dio_failure_mapper.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/product_model.dart';

import '/repository/button_nav_bar/order_repository.dart';
import 'package:mobile/models/button_nav_bar/order_model.dart';
import 'order_remote_ds.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remote);
  final OrderRemoteDataSource _remote;

  @override
  Future<Result<List<OrderModel>>> getMyOrders() async {
    try {
      final json = await _remote.fetchMyOrders();
      return Success(json.map(OrderModel.fromJson).toList());
    } on DioException catch (e) {
      return Error<List<OrderModel>>(mapDioExceptionToFailure(e));
    } catch (_) {
      return Error<List<OrderModel>>(const UnknownFailure());
    }
  }

  @override
  Future<Result<List<ProductModel>>> getMyProducts() async {
    try {
      final json = await _remote.fetchMyProducts();
      return Success(json.map(ProductModel.fromJson).toList());
    } on DioException catch (e) {
      return Error<List<ProductModel>>(mapDioExceptionToFailure(e));
    } catch (_) {
      return Error<List<ProductModel>>(const UnknownFailure());
    }
  }
}