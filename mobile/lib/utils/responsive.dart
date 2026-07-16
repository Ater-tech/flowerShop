import 'package:flutter/material.dart';

/// Barcha breakpoint qiymatlari shu yerda saqlanadi
class AppBreakpoints {
  AppBreakpoints._(); // instance yaratilmasin

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

enum DeviceType { mobile, tablet, desktop }

/// BuildContext orqali to'g'ridan-to'g'ri chaqirish uchun extension
extension ResponsiveContext on BuildContext {
  Size get _size => MediaQuery.sizeOf(this);

  double get screenWidth => _size.width;
  double get screenHeight => _size.height;

  DeviceType get deviceType {
    final width = screenWidth;
    if (width < AppBreakpoints.mobile) return DeviceType.mobile;
    if (width < AppBreakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Qurilmaga qarab moslashuvchan qiymat qaytaradi
  /// Masalan: context.responsive(mobile: 16, tablet: 24, desktop: 32)
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Ekran kengligiga nisbatan foizli qiymat (masalan 0.8 = 80%)
  double widthPercent(double percent) => screenWidth * percent;
  double heightPercent(double percent) => screenHeight * percent;
}

/// Ekran turiga qarab boshqa-boshqa widget qaytaruvchi yordamchi widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    switch (context.deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}