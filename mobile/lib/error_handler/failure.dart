import 'package:dio/dio.dart';

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class WrongCredentialsFailure extends Failure {
  const WrongCredentialsFailure() : super("Login yoki parol noto'g'ri");
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure() : super("Foydalanuvchi topilmadi");
}

class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure()
    : super("Bu email allaqachon ro'yxatdan o'tgan");
}

// failure.dart ichida, NetworkFailure klassiga qo'shiladi
class NetworkFailure extends Failure {
  const NetworkFailure(this.message) : super('');
  @override
  // ignore: overridden_fields
  final String message;
  

  factory NetworkFailure.fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkFailure('Ulanish vaqti tugadi'),
      DioExceptionType.connectionError =>
        const NetworkFailure('Internet aloqasi yo\'q'),
      DioExceptionType.badResponse =>
        NetworkFailure('Server xatosi: ${e.response?.statusCode}'),
      _ => NetworkFailure(e.message ?? 'Noma\'lum xatolik'),
    };
  }
}

class ServerFailure extends Failure {
  const ServerFailure() : super("Server xatoligi, keyinroq urinib ko'ring");
}

class CancelledFailure extends Failure {
  const CancelledFailure() : super("Bekor qilindi");
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super("Kutilmagan xatolik");
}

class ValidationFailure extends Failure {
  final Map<String, dynamic> errors; // DRF qaytargan {"field": ["xato"]}

  ValidationFailure(this.errors) : super(_buildMessage(errors));

  static String _buildMessage(Map<String, dynamic> errors) {
    if (errors.isEmpty) return "Kiritilgan ma'lumotlarda xatolik bor";
    final firstKey = errors.keys.first;
    final firstValue = errors[firstKey];
    final text = firstValue is List
        ? firstValue.first.toString()
        : firstValue.toString();
    return text;
  }
}

class PaymentRequiredFailure extends Failure {
  final List<String> options; // ["premium", "pay_per_product"]
  final int pricePerProduct;

  const PaymentRequiredFailure({
    required String message,
    required this.options,
    required this.pricePerProduct,
  }) : super(message);
}

class CacheFailure extends Failure{
  const CacheFailure(): super("Saqlangan ma'lumotni o'qishda xatolik");
}

