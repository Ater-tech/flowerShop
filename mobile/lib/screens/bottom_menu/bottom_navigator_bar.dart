import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/providers/bottom_nav_provider.dart';
import 'package:mobile/screens/crud_product/add_product_page.dart';

class HomeBottomNavBar extends ConsumerWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 2:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            }
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
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Xabarlar'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Sell'),
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
