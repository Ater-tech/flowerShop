import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Yo'llarni o'zingizdagi package nomiga moslang:
import 'package:mobile/error_handler/orders_deps.dart';
import 'package:mobile/providers/order_providers/orders_providers.dart';
import 'package:mobile/providers/shop_provider.dart';
import 'package:mobile/server/api_endpoints.dart';

/// Backend: POST /api/seller/upgrade-to-business/  body {"confirm": true}
class SellerUpgradeRepository {
  SellerUpgradeRepository(this._dio);
  final Dio _dio;

  Future<Result<bool>> upgrade() => guardRequest(() async {
        await _dio.post(ApiEndpoints.upgradeToBusiness, data: {'confirm': true});
        return true;
      });
}

final sellerUpgradeRepositoryProvider = Provider<SellerUpgradeRepository>(
  (ref) => SellerUpgradeRepository(ref.watch(apiProvider).dio),
);

/// Profil/sozlamalardagi "Rasmiy do'konga o'tish" tugmasi bosilganda chaqiring.
Future<void> showUpgradeToBusinessDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Rasmiy do'konga o'tish"),
      content: const Text(
        "• Eski buyurtmalar tarixingiz ko'rinmay qoladi\n"
        "• Savatingiz tozalanadi\n"
        "• Rasmiy do'kon hisobi xarid qila olmaydi\n"
        "• Faol buyurtmalaringiz bo'lsa, o'tib bo'lmaydi\n\n"
        "Bu amalni qaytarib bo'lmaydi.",
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor qilish')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("O'tish")),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final result = await ref.read(sellerUpgradeRepositoryProvider).upgrade();
  if (!context.mounted) return;

  switch (result) {
    case Success():
      // Oynalar o'zgardi: faqat "Mahsulotlarim" qoladi
      ref.invalidate(ordersMetaProvider);
      ref.invalidate(buyingOrdersProvider);
      ref.invalidate(sellingOrdersProvider);
      ref.invalidate(shopRepositoryProvider);
      // TODO: profil / do'kon provider'laringizni ham yangilang (shop_type o'zgardi)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Rasmiy do'konga o'tdingiz")));
    case Error(:final failure):
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage(failure))));
  }
}
