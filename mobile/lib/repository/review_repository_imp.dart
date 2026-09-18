// data/repositories/review_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/error_handler/failure.dart';
import 'package:mobile/models/review_model.dart';
import 'package:mobile/server/api_endpoints.dart';
import 'review_repository.dart';
class ReviewRepositoryImpl implements ReviewRepository {
  final Dio dio;
  ReviewRepositoryImpl({required this.dio});
  @override
  Future<Result<List<Review>>> fetchProductReviews(
    int productId, {
    int pageSize = 5,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.reviews,
        queryParameters: {'product': productId, 'page_size': pageSize},
      );
      final results = response.data['results'] as List;
      final reviews = results
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(reviews);
    } on DioException catch (e) {
      return Error(NetworkFailure.fromDioException(e));
    }
  }
}