import 'package:mobile/error_handler/error_result.dart';
import '/models/cart_item_model.dart';

abstract interface class CartRepository {
  Future<Result<List<CartItemModel>>> getCartItems();
  Future<Result<CartItemModel>> addProduct(int productId, int quantity);
  Future<Result<CartItemModel>> updateQuantity(int itemId, int quantity);
  Future<Result<bool>> removeItem(int itemId);
}