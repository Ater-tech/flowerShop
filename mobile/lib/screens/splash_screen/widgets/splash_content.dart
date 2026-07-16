import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashContent extends StatelessWidget {
  final AnimationController controller;
  final double slowMotionFactor;
  final String message;
 
  const SplashContent({
    super.key,
    required this.controller,
    required this.slowMotionFactor,
    required this.message,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [        
        Expanded(
          flex: 8,
          child: Lottie.asset(
            'assets/lottie/bouquet.lottie',
            controller: controller,
            repeat: false,
            onLoaded: (composition) {
              // Tabiiy davomiylikni ko'paytirib, animatsiyani sekinlashtiramiz.
              controller
                ..duration = composition.duration * slowMotionFactor * 0.5
                ..forward();
            },
          ),
        ),
        Expanded(flex: 1, child: SizedBox()),
        // Yozuvlar orasida yumshoq fade o'tishi.
        Expanded(
          flex: 1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Center(
              child: Text(
                message,
                key: ValueKey<String>(message),
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}