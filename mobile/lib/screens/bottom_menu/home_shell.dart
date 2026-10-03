import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/bottom_nav_provider.dart';
import 'package:mobile/screens/bottom_menu/bottom_navigator_bar.dart';
import 'package:mobile/screens/bottom_menu/orders_page.dart';
import 'package:mobile/screens/bottom_menu/cart_page.dart';
import 'package:mobile/screens/bottom_menu/profile_page.dart';
import 'package:mobile/screens/home_screen/product_menu/main_page.dart';

/// Bottom nav ortidagi "qobiq". IndexedStack har tabni FAQAT bir marta
/// quradi va keyin shunchaki ko'rsatib/yashirib turadi — shuning uchun
/// Orders sahifasidagi ichki tab yoki scroll holati tab almashganda
/// yo'qolmaydi. "Soting" (index 2) bu yerda umuman ishtirok etmaydi,
/// chunki u push bilan ochiladi (HomeBottomNavBar'ga qarang).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomePage(), //HomePage()
          OrdersPage(),
          SizedBox.shrink(), // index 2: hech qachon ko'rinmaydi
          CartPage(), // CartPage()
          ProfilePage(), //ProfilePage()
        ],
      ),
      bottomNavigationBar: const HomeBottomNavBar(),
    );
  }
}