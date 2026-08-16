import 'package:flutter/material.dart';
import 'package:mobile/models/shop_model.dart';

class ShopDropdown extends StatelessWidget {
  const ShopDropdown({
    super.key,
    required this.shops,
    required this.selectedShopId,
    required this.onChanged,
  });

  final List<ShopModel> shops;
  final int? selectedShopId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: selectedShopId,
      decoration: const InputDecoration(labelText: "Do'kon"),
      items: shops.map((s) {
        return DropdownMenuItem(value: s.id, child: Text(s.name));
      }).toList(),
      onChanged: onChanged,
    );
  }
}