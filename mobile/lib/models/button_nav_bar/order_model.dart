class OrderItemModel {
  final int id;
  final int? product;
  final int? bouquetComposition;
  final String nameSnapshot;
  final double unitPriceSnapshot;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.product,
    required this.bouquetComposition,
    required this.nameSnapshot,
    required this.unitPriceSnapshot,
    required this.quantity,
  });

  double get lineTotal => unitPriceSnapshot * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      product: json['product'] as int?,
      bouquetComposition: json['bouquet_composition'] as int?,
      nameSnapshot: json['name_snapshot'] as String,
      unitPriceSnapshot: double.parse(json['unit_price_snapshot'].toString()),
      quantity: json['quantity'] as int,
    );
  }
}

class OrderModel {
  final int id;
  final int shop;
  final String status; // new | accepted | delivering | completed | cancelled
  final double totalPrice;
  final bool isCompleted;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.shop,
    required this.status,
    required this.totalPrice,
    required this.isCompleted,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      shop: json['shop'] as int,
      status: json['status'] as String,
      totalPrice: double.parse(json['total_price'].toString()),
      isCompleted: json['is_completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}