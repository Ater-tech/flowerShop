import 'package:flutter/material.dart';
import 'package:mobile/models/shop_model.dart';

class ShopInfoCard extends StatelessWidget {
  const ShopInfoCard({super.key, required this.shop});
  final ShopModel shop;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          shop.shopType == ShopType.personal
              ? Icons.person_outline
              : Icons.storefront_outlined,
        ),
        title: Text(shop.name),
        subtitle: Text(
          shop.shopType == ShopType.personal ? 'Shaxsiy' : "Rasmiy do'kon",
        ),
      ),
    );
  }
}
