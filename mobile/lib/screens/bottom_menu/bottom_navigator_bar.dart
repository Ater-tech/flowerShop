import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/button_nav_bar/bottom_nav_provider.dart';
import 'package:mobile/screens/crud_product/add_product_entry_page.dart';

/// "Soting" (index 2) alohida oqim — push bilan ochiladi, currentIndex
/// o'zgarmaydi. Qolgan to'rttasi doimiy tab: ularni HomeShell'dagi
/// IndexedStack ko'rsatadi (pastga qarang).
class HomeBottomNavBar extends ConsumerWidget {
  const HomeBottomNavBar({super.key});

  static const int sellIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == sellIndex) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddProductEntryPage()),
          );
          return;
        }
        ref.read(bottomNavIndexProvider.notifier).state = index;
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6C3CE9),
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Bosh sahifa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Buyurtmalar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Soting'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Savat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}