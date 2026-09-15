import 'package:flutter/material.dart';
import 'package:mobile/models/shop_model.dart';

class DeliveryInfoSection extends StatelessWidget {
  const DeliveryInfoSection({super.key, required this.shop});
  final ShopModel shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yetkazib berish: ${shop.cityName ?? "Noma\'lum shahar"}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text(
                  '1-2 kun ichida yetkaziladi',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
