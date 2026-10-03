import 'package:mobile/models/product_model.dart'; // o'zingizdagi yo'l

/// Custom dasta uchun hozircha faqat narx va id — to'liq konstruktor UI
/// keyingi bosqichda qilinadi, savat esa shu minimal ma'lumot bilan ham
/// to'g'ri ishlaydi.
class CartItemModel {
  final int id;
  final ProductModel? product;
  final int? bouquetCompositionId;
  final double? bouquetTotalPrice;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.bouquetCompositionId,
    required this.bouquetTotalPrice,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  bool get isBouquet => bouquetCompositionId != null;
  String get displayName => product?.name ?? "O'zi yasalgan dasta";
  // Guruhlash uchun: hozircha faqat tayyor mahsulotlar do'kon bo'yicha
  // guruhlanadi. Custom dasta uchun builder UI qurilgach, shop_detail
  // backend javobiga qo'shib, shu yerga ham ulanadi.
  int? get shopId => product?.shop.id;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final bouquetDetail = json['bouquet_detail'] as Map<String, dynamic>?;
    return CartItemModel(
      id: json['id'] as int,
      product: json['product_detail'] != null
          ? ProductModel.fromJson(json['product_detail'] as Map<String, dynamic>)
          : null,
      bouquetCompositionId: json['bouquet_composition'] as int?,
      bouquetTotalPrice:
          bouquetDetail != null ? double.parse(bouquetDetail['total_price'].toString()) : null,
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      lineTotal: double.parse(json['line_total'].toString()),
    );
  }
}