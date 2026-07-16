import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Splash ekranida animatsiya ostida ketma-ket chiqadigan yozuvlar.
/// Har biri o'zgarishi orasidagi vaqtni shu yerdan boshqarasiz.
class SplashMessageController extends Notifier<String> {
  static const List<String> _messages = [
    "...",
    "Welcome to Floréa",
    "Growing Happiness",   
    "Your bouquet is being prepared...",
    "Checking account ...",
  ];

  static const Duration _interval = Duration(milliseconds: 1500);

  int _index = 0;
  Timer? _timer;

  @override
  String build() {
    // Notifier tugatilganda timer ham to'xtatiladi (memory leak bo'lmasligi uchun).
    ref.onDispose(() => _timer?.cancel());
    _index = 0;
    _startSequence();
    return _messages[_index];
  }

  void _startSequence() {
    _timer = Timer.periodic(_interval, (timer) {
      _index++;
      if (_index >= _messages.length) {
        timer.cancel();
        return;
      }
      state = _messages[_index];
    });
  }

  /// Barcha yozuvlar ketma-ketligi tugashi uchun taxminiy umumiy vaqt.
  static Duration get totalDuration => _interval * _messages.length;
}

final splashMessageProvider =
    NotifierProvider<SplashMessageController, String>(
  SplashMessageController.new,
);