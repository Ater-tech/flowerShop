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
