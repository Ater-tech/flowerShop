import 'package:mobile/error_handler/error_result.dart'; 
import 'package:mobile/models/product_model.dart';
import 'package:mobile/models/button_nav_bar/order_model.dart';

abstract interface class OrderRepository {
  Future<Result<List<OrderModel>>> getMyOrders();
  Future<Result<List<ProductModel>>> getMyProducts();
  Future<Result<List<OrderModel>>> checkout();
}