import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/auth/controllers/auth_controllers.dart';

final authProvider = StateNotifierProvider<AuthController, AsyncValue<String?>>(
  (ref) => AuthController(),
);
