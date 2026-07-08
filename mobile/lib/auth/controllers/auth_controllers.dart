import 'package:mobile/server/user_api_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthController extends StateNotifier<AsyncValue<String?>> {
  AuthController() : super(const AsyncValue.data(null));

  final UserApiService api = UserApiService();

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final token = await api.login(email, password);
      state = AsyncValue.data(token);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
