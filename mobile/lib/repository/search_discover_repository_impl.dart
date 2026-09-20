import 'package:dio/dio.dart';
import 'package:mobile/error_handler/dio_failure_mapper.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/error_handler/failure.dart'; 
import 'package:mobile/models/product_model.dart'; 
import '../../repository/search_discover_repository.dart';
import '../storage/search_discover_remote_ds.dart';

class SearchDiscoverRepositoryImpl implements SearchDiscoverRepository {
  SearchDiscoverRepositoryImpl(this._remote);
  final SearchDiscoverRemoteDataSource _remote;

  @override
  Future<Result<List<ProductModel>>> getRecommended({int limit = 10}) =>
      _load(SearchDiscoverRemoteDataSource.recommendedPath, limit);

  @override
  Future<Result<List<ProductModel>>> getPopular({int limit = 10}) =>
      _load(SearchDiscoverRemoteDataSource.popularPath, limit);

  Future<Result<List<ProductModel>>> _load(String path, int limit) async {
    try {
      final json = await _remote.fetch(path, limit: limit);
      return Success(json.map(ProductModel.fromJson).toList());
    } on DioException catch (e) {
      return Error<List<ProductModel>>(mapDioExceptionToFailure(e));
    } catch (_) {
      return Error<List<ProductModel>>(const UnknownFailure());
    }
  }
}
