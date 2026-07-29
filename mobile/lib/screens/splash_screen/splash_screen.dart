import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/screens/home_screen/product_menu/main_page.dart';
import 'package:mobile/screens/home_screen/register/log_in_page.dart';
import 'package:mobile/screens/splash_screen/widgets/splash_content.dart';
import 'package:mobile/screens/splash_screen/controllers/splash_controller.dart';
import 'package:mobile/screens/splash_screen/widgets/splash_error.dart';
import 'package:mobile/screens/splash_screen/controllers/splash_message_controller.dart';
import 'package:mobile/screens/splash_screen/splash_status.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashState();
}

class _SplashState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controllerLottie;
  static const double _slowMotionFactor = 2.5;
  @override
  void initState() {
    super.initState();
    _controllerLottie = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controllerLottie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(splashControllerProvider);
    final message = ref.watch(splashMessageProvider);

    ref.listen<SplashStatus>(splashControllerProvider, ((previous, next) {
      switch (next) {
        case SplashStatus.authenticated:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        case SplashStatus.unauthenticated:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LogInPage()),
          );
        case SplashStatus.loading:
        case SplashStatus.error:
          break;
      }
    }));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: status == SplashStatus.error
              ? SplashError(
                  onRetry: () =>
                      ref.read(splashControllerProvider.notifier).retry(),
                )
              : SplashContent(
                  controller: _controllerLottie,
                  slowMotionFactor: _slowMotionFactor,
                  message: message,
                ),
        ),
      ),
    );
  }
}
