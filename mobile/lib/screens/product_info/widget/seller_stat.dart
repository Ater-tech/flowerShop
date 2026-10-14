import 'package:flutter/material.dart';
import 'package:mobile/models/shop_model.dart';

class SellerStatsRow extends StatelessWidget {
  const SellerStatsRow({super.key, required this.shop});
  final ShopModel shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.shopping_bag_outlined, 
            label: '${shop.totalSold} sotildi'),
          _StatItem(
            icon: Icons.local_florist_outlined, 
            label: '${shop.productCount} sharh'),
          _StatItem(icon: Icons.storefront_outlined, 
          label: shop.shopType.apiValue == 'business' ? 'Biznes':'Shaxsiy'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.amber.shade700),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}