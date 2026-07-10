import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/auth/controllers/auth_controllers.dart';
import 'package:mobile/repository/token_storage.dart';
import 'package:mobile/server/api_main_service.dart';
import 'package:mobile/server/user_api_server.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());
final apiProvider = Provider<ApiMainService>(
  (ref) => ApiMainService(storage: ref.read(tokenStorageProvider)),
);

final authReprositoryProvider = Provider<UserApiService>(
  (ref) => UserApiService(ref.read(apiProvider)),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.read(authReprositoryProvider));
    });
