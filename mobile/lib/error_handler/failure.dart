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

class NetworkFailure extends Failure {
  const NetworkFailure() : super("Internet aloqasini tekshiring");
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
