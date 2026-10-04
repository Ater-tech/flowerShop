import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/repository/auth_reprository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/repository/token_repository.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthReprository _repository;
  final TokenRepository _tokenRepository;
  AuthController(this._repository, this._tokenRepository) : super(const AsyncValue.data(null));

  Future<void> login(String username, String password, bool rememberMe) async {
    state = const AsyncValue.loading();
    try {
      await _repository.login(
        username: username,
        password: password,
        rememberMe: rememberMe,
      );

      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> register(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.register(username: username, password: password);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<String?> refresh() async {
    try {
      return await _tokenRepository.refreshToken();
    } catch (_){
      return "Yangilashda xatolik";
    }
  }

  Future<String?> logout() async {
    try{await _repository.logout();
    return null;} catch (_){
      return "Akkauntdan chiqishda xatolik ro'y berdi";
    }
  }
  
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
      (ref) => AuthController(
        ref.read(authReprositoryProvider),
        ref.read(tokenRepositoryProvider),
      ),
    );
