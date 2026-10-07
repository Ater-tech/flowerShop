import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/dio_failure_mapper.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/flower_model.dart';
import 'package:mobile/providers/repo_providers.dart';

class FavouriteRepository {
  final Dio _dio;
  FavouriteRepository(this._dio);

  Future<Result<List<FlowerModel>>> fetchFavourites() async {
    try {
      final res = await _dio.get('/api/favourites/');
      final raw = res.data;
      // pagination yoqilgan bo'lsa {results: [...]}, bo'lmasa oddiy list
      final list = (raw is Map ? raw['results'] : raw) as List;

      final flowers = list
          .map((e) => FlowerModel.fromJSON(e['flower_detail'] as Map<String, dynamic>))
          .toList();
      return Success(flowers);
    } on DioException catch (e) {
      return Error(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<bool>> toggle(int flowerId) async {
    try {
      final res = await _dio.post('/api/favourites/toggle/', data: {'flower': flowerId});
      return Success(res.data['is_favourited'] as bool);
    } on DioException catch (e) {
      return Error(mapDioExceptionToFailure(e));
    }
  }
}

final favouriteRepositoryProvider = Provider<FavouriteRepository>(
  (ref) => FavouriteRepository(ref.watch(apiProvider).dio),
);