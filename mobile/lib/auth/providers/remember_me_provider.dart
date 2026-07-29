// lib/features/auth/presentation/providers/remember_me_provider.dart
import 'package:flutter_riverpod/legacy.dart';

final rememberMeProvider = StateProvider.autoDispose<bool>((ref) => false);