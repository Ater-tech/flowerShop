import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_check_repo.dart';
import '../splash_status.dart';
import 'splash_message_controller.dart';

/// Splash ekranining butun business logikasi shu yerda.
/// UI faqat holatni "watch" qiladi — setState umuman ishlatilmaydi.
class SplashController extends Notifier<SplashStatus> {
  @override
  SplashStatus build() {
    // Notifier yaratilishi bilanoq tekshiruvni boshlaymiz.
    _init();
    return SplashStatus.loading;
  }

  Future<void> _init() async {
    try {
      // Lottie animatsiyasi (sekinlashtirilgan holda) va matnlar ketma-ketligi
      // to'liq ko'rinib bo'lguncha ekranni kamida shuncha vaqt ushlab turamiz.
      final minDelay = Future.delayed(SplashMessageController.totalDuration);

      final repo = ref.read(authCheckRepositoryProvider);
      final results = await Future.wait([repo.hasValidSession(), minDelay]);

      final isLoggedIn = results.first as bool;
      state = isLoggedIn
          ? SplashStatus.authenticated
          : SplashStatus.unauthenticated;
    } catch (_) {
      state = SplashStatus.error;
    }
  }

  /// Xatolik bo'lganda "Qayta urinish" tugmasi uchun.
  void retry() {
    state = SplashStatus.loading;
    _init();
  }
}

final splashControllerProvider =
    NotifierProvider<SplashController, SplashStatus>(SplashController.new);