import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/product_detail_provider.dart';
class WeeklySalesSection extends ConsumerWidget {
  final int productId;

  const WeeklySalesSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productDetailProvider(productId));

    return switch (asyncProduct) {
      AsyncData(:final value) => _buildContent(context, value.weeklySoldCount),
      AsyncError() => const SizedBox.shrink(), // xato bo'lsa section umuman ko'rinmaydi
      _ => _buildSkeleton(),
    };
  }

  Widget _buildContent(BuildContext context, int weeklySoldCount) {
    if (weeklySoldCount <= 0) {
      return const SizedBox.shrink(); // hali sotuv bo'lmagan mahsulotda section yashiriladi
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 6),
          Text(
            "Bu hafta $weeklySoldCount marta sotilgan",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 28,
      width: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}