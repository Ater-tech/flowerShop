import 'package:dio/dio.dart';
import 'package:mobile/error_handler/failure.dart'; 
import 'package:mobile/error_handler/dio_failure_mapper.dart'; 
import 'package:mobile/error_handler/error_result.dart'; 

import './cart_repository.dart';
import '/models/cart_item_model.dart';
import 'cart_remote_ds.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remote);
  final CartRemoteDataSource _remote;

  @override
  Future<Result<List<CartItemModel>>> getCartItems() async {
    try {
      final json = await _remote.fetchItems();
      return Success(json.map(CartItemModel.fromJson).toList());
    } on DioException catch (e) {
      return Error<List<CartItemModel>>(mapDioExceptionToFailure(e));
    } catch (_) {
      return Error<List<CartItemModel>>(const UnknownFailure());
    }
  }

  @override
  Future<Result<CartItemModel>> addProduct(int productId, int quantity) async {
    try {
      final json = await _remote.addProduct(productId, quantity);
      return Success(CartItemModel.fromJson(json));
    } on DioException catch (e) {
      return Error<CartItemModel>(mapDioExceptionToFailure(e));
    } catch (_) {
      return Error<CartItemModel>(const UnknownFailure());
    }
  }

  @override
  Future<Result<CartItemModel>> updateQuantity(int itemId, int quantity) async {
    try {
      final json = await _remote.updateQuantity(itemId, quantity);
      return Success(CartItemModel.fromJson(json));
    } on DioException catch (e) {
      return Error<CartItemModel>(mapDioExceptionToFailure(e));
    } catch (_) {
      return Error<CartItemModel>(const UnknownFailure());
    }
  }

  @override
  Future<Result<bool>> removeItem(int itemId) async {
    try {
      await _remote.removeItem(itemId);
      return const Success(true);
    } on DioException catch (e) {
      return Error<bool>(mapDioExceptionToFailure(e));
    } catch (_) {
      return Error<bool>(const UnknownFailure());
    }
  }
}