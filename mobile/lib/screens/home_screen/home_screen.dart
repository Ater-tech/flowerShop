// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/providers/bottom_nav_provider.dart';
import 'package:mobile/screens/home_screen/product_menu/main_page.dart';
import 'package:mobile/screens/bottom_menu/messages_page.dart';
import 'package:mobile/screens/bottom_menu/cart_page.dart';
import 'package:mobile/screens/bottom_menu/profile_page.dart';
import 'package:mobile/screens/bottom_menu/bottom_navigator_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    MessagesPage(),
    SizedBox.shrink(), // index 2 - "Sell" push bo'lgani uchun bo'sh widget
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: const HomeBottomNavBar(),
    );
  }
}