import 'package:flutter/material.dart';
import 'package:mobile/models/product_model.dart';

class PriceSection extends StatelessWidget {
  const PriceSection({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPercent != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Text(
            '${hasDiscount ? product.discountPercent : product.price} so\'m',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (hasDiscount) ...[
            const SizedBox(width: 8),
            Text(
              '${product.price} so\'m',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}