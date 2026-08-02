import 'package:mobile/auth/providers/repo_providers.dart';
import 'package:mobile/repository/auth_reprository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthReprository _repository;
  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<void> login(
    String username, 
    String password, 
    bool rememberMe,
    ) async {
    
    state = const AsyncValue.loading();
    try {
      await _repository.login(username: username, password: password, rememberMe: rememberMe);
      
      state = const AsyncValue.data(null);

    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> register(
    String username,
    String password
  ) async{
    state = const AsyncValue.loading();
    try{
      await _repository.register(username: username, password: password);
      state = const AsyncValue.data(null); 
    } catch (e, s){
      state = AsyncValue.error(e,s);
    }
  }

  Future<bool> refresh() async{
    return await Future.delayed(Duration(seconds: 10), );
  } 
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref.read(authReprositoryProvider))
);
