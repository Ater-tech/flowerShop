import 'package:mobile/server/user_api_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final UserApiService repository;

  AuthController(this.repository) : super(const AsyncValue.data(null));

  Future<bool> login(
    String email, 
    String password) async {
    
    state = const AsyncValue.loading();
    try {
      await repository.login(email, password);
      state = AsyncValue.data(null);
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }
}
