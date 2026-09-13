// domain/repositories/review_repository.dart
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/review_model.dart';

abstract class ReviewRepository {
  Future<Result<List<Review>>> fetchProductReviews(int productId, {int pageSize = 5});
}