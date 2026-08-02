import 'package:dio/dio.dart';
import 'failure.dart';

Failure mapDioExceptionToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();

    case DioExceptionType.cancel:
      return const CancelledFailure();

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode >= 500) {
        return const ServerFailure();
      }
      // 4xx statuslar uchun umumiy holat — aniqroq turlash kerak bo'lsa,
      // chaqiruvchi repository o'zi status kodni tekshirib, moslash Failure qaytaradi
      return const ServerFailure();

    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return const NetworkFailure();
  }
}
