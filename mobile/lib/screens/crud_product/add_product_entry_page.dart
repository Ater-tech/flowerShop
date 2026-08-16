import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/shop_provider.dart';
import 'package:mobile/screens/crud_product/add_product_page.dart';
import 'package:mobile/screens/crud_product/seller_account/shop_on_boarding.dart';
import 'package:mobile/screens/crud_product/shop_dropdown.dart';
import 'package:mobile/screens/crud_product/shop_info_card.dart';

class AddProductEntryPage extends ConsumerStatefulWidget {
  const AddProductEntryPage({super.key});

  @override
  ConsumerState<AddProductEntryPage> createState() => _AddProductEntryPageState();
}

class _AddProductEntryPageState extends ConsumerState<AddProductEntryPage> {
  int? _selectedShopId;

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(sellerShopsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Mahsulot qo'shish")),
      body: shopsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (shops) {
          // Birinchi yuklanganda default shopni avtomatik tanlaymiz
          if (_selectedShopId == null && shops.isNotEmpty) {
            final defaultShop = shops.firstWhere(
              (s) => s.isDefault,
              orElse: () => shops.first,
            );
            _selectedShopId = defaultShop.id;
          }

          final selectedShop = shops.isEmpty
              ? null
              : shops.firstWhere(
                  (s) => s.id == _selectedShopId,
                  orElse: () => shops.first,
                );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (shops.isEmpty)
                  const Text(
                    "Sizda hali do'kon yo'q. Davom etish uchun avval do'kon qo'shing.",
                  )
                else if (shops.length == 1)
                  ShopInfoCard(shop: shops.first)
                else
                  ShopDropdown(
                    shops: shops,
                    selectedShopId: _selectedShopId,
                    onChanged: (id) => setState(() => _selectedShopId = id),
                  ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Do'kon qo'shish"),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShopOnboardingPage()),
                    );
                    ref.invalidate(sellerShopsProvider);
                  },
                ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed: selectedShop == null
                      ? null // shops bo'sh bo'lsa — tugma o'chiq (yonmaydi)
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductPage(shop: selectedShop),
                            ),
                          ),
                  child: Text(
                    selectedShop == null
                        ? 'Davom etish'
                        : '${selectedShop.name} sifatida davom etish',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}