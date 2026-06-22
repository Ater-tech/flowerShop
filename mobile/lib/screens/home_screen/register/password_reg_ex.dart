// import 'package:'
bool regExPassword(String? password) {
  if (password == null) return false;
  return RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>]).+$',
  ).hasMatch(password);
}
