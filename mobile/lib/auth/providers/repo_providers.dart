import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/repository/auth_reprository.dart';
import 'package:mobile/repository/token_repository.dart';
import 'package:mobile/storage/token_storage.dart';
import 'package:mobile/repository/user_repository.dart';
import 'package:mobile/server/api_main_service.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());
final rememberMeProvider = StateProvider<bool>((ref)=>false);
final apiProvider = Provider<ApiMainService>(
  (ref) => ApiMainService(storage: ref.watch(tokenStorageProvider)),
);

final tokenRepositoryProvider = Provider<TokenRepository>(
  (ref) => ref.watch(apiProvider).tokenRepository,);

final authReprositoryProvider = Provider<AuthReprository>(
  (ref) => ref.watch(apiProvider).authReprository,
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => ref.watch(apiProvider).userReprository,
);
