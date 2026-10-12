// Orders feature uchun YAGONA moslashtirish nuqtasi.
// Faqat shu fayldagi import yo'llarini o'zingizdagi joylarga moslang (VS Code: Quick Fix).
import 'package:dio/dio.dart';

import 'failure.dart';
import 'dio_failure_mapper.dart'; // mapDioExceptionToFailure
import 'error_result.dart';

export 'failure.dart';
export 'package:mobile/providers/repo_providers.dart'; // apiMainServiceProvider
export 'error_result.dart';

/// Backend qaytaradigan biznes-qoida kodlari (SimpleJWT'ning "token_not_valid" kabi kodlari bilan adashmasligi uchun).
const _ruleCodes = {
  'self_purchase', 'role_not_allowed', 'action_not_allowed', 'invalid_transition',
  'method_not_available', 'empty_cart', 'missing_selection', 'not_found',
  'active_orders', 'not_personal_seller', 'confirm_required', 'not_a_seller',
  'shop_has_orders', 'forbidden',
};

/// UI'da ko'rsatiladigan matn. Failure'ingizda `message` bo'lmasa, shu yerda moslang.
String failureMessage(Failure f) => f.message;

Failure toFailure(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['code'] is String && _ruleCodes.contains(data['code'])) {
    return OrderRuleFailure(
      data['detail']?.toString() ?? 'Order rule: Xatolik yuz berdi',
      data['code'] as String,
    );
  }
  return mapDioExceptionToFailure(e);
}

/// Dio so'rovini Result<T> ga o'raydi (loyihangizdagi Result/Failure naqshi bo'yicha).
Future<Result<T>> guardRequest<T>(Future<T> Function() body) async {
  try {
    return Success<T>(await body());
  } on DioException catch (e) {
    return Error<T>(toFailure(e));
  }
}
