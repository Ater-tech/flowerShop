import 'order_enums.dart';

double _toDouble(Object? v) => v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);

DateTime? _toDate(Object? v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;

class OrderNotice {
  const OrderNotice({required this.code, required this.text});
  final String code;
  final String text;

  factory OrderNotice.fromJson(Map<String, dynamic> j) =>
      OrderNotice(code: j['code'] as String, text: j['text'] as String);
}

class OrderShopInfo {
  const OrderShopInfo({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
  });
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;

  factory OrderShopInfo.fromJson(Map<String, dynamic> j) => OrderShopInfo(
        id: j['id'] as int,
        name: (j['name'] as String?) ?? '',
        address: (j['address'] as String?) ?? '',
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
      );
}

/// Kelishuvdan (accepted) keyingina keladi.
class OrderCounterparty {
  const OrderCounterparty({required this.name, this.phone});
  final String name;
  final String? phone;

  factory OrderCounterparty.fromJson(Map<String, dynamic> j) =>
      OrderCounterparty(name: (j['name'] as String?) ?? '', phone: j['phone'] as String?);
}

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    this.productId,
    this.bouquetCompositionId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });
  final int id;
  final int? productId;
  final int? bouquetCompositionId;
  final String name;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        id: j['id'] as int,
        productId: j['product'] as int?,
        bouquetCompositionId: j['bouquet_composition'] as int?,
        name: (j['name_snapshot'] as String?) ?? '',
        unitPrice: _toDouble(j['unit_price_snapshot']),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
      );
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.shopId,
    required this.status,
    required this.totalPrice,
    required this.isCompleted,
    required this.fulfillmentMethod,
    required this.meetupNote,
    this.desiredAt,
    this.expiresAt,
    required this.role,
    required this.stage,
    required this.notices,
    required this.actions,
    required this.canReview,
    required this.shopInfo,
    this.counterparty,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final int shopId;
  final OrderStatus status;
  final double totalPrice;

  /// Arxiv (completed/cancelled/rejected/expired): ro'yxat pastida, xira ko'rinadi.
  final bool isCompleted;
  final FulfillmentMethod fulfillmentMethod;
  final String meetupNote;
  final DateTime? desiredAt;
  final DateTime? expiresAt;
  final OrderRole role;
  final OrderStage stage;
  final List<OrderNotice> notices;

  /// Backend aytadigan, shu foydalanuvchi hozir bajara oladigan amallar.
  final List<OrderAction> actions;
  final bool canReview;
  final OrderShopInfo shopInfo;
  final OrderCounterparty? counterparty;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  bool get isSelling => role == OrderRole.selling;

  /// Xaridor/sotuvchi uchun turlicha bosqich nomi.
  String get stageLabel {
    switch (stage) {
      case OrderStage.pending:
        return isSelling ? "Yangi so'rov" : 'Javob kutilmoqda';
      case OrderStage.incoming:
        return 'Kelishilgan buyurtma kelmoqda';
      case OrderStage.pickupInProgress:
        return 'Olish jarayoni';
      case OrderStage.agreed:
        return fulfillmentMethod == FulfillmentMethod.sellerDelivery
            ? 'Buyurtma yetkazilmoqda'
            : 'Kelishilgan';
      case OrderStage.archived:
        if (status == OrderStatus.completed) return isSelling ? 'Yetkazildi' : 'Olingan';
        return status.label;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'] as int,
        shopId: j['shop'] as int,
        status: OrderStatus.parse(j['status'] as String),
        totalPrice: _toDouble(j['total_price']),
        isCompleted: (j['is_completed'] as bool?) ?? false,
        fulfillmentMethod: FulfillmentMethod.parse(j['fulfillment_method'] as String),
        meetupNote: (j['meetup_note'] as String?) ?? '',
        desiredAt: _toDate(j['desired_at']),
        expiresAt: _toDate(j['expires_at']),
        role: OrderRole.parse(j['role'] as String),
        stage: OrderStage.parse(j['stage'] as String),
        notices: ((j['notices'] as List?) ?? const [])
            .map((e) => OrderNotice.fromJson(e as Map<String, dynamic>))
            .toList(),
        actions: ((j['actions'] as List?) ?? const [])
            .map((e) => OrderAction.tryParse(e as String))
            .whereType<OrderAction>()
            .toList(),
        canReview: (j['can_review'] as bool?) ?? false,
        shopInfo: OrderShopInfo.fromJson(j['shop_info'] as Map<String, dynamic>),
        counterparty: j['counterparty'] == null
            ? null
            : OrderCounterparty.fromJson(j['counterparty'] as Map<String, dynamic>),
        createdAt: _toDate(j['created_at']) ?? DateTime.now(),
        items: ((j['items'] as List?) ?? const [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Checkout paytida xaridorning bitta do'kon bo'yicha tanlovi.
class ShopSelection {
  const ShopSelection({
    required this.shopId,
    required this.method,
    this.meetupNote = '',
    this.desiredAt,
  });
  final int shopId;
  final FulfillmentMethod method;
  final String meetupNote;
  final DateTime? desiredAt;

  Map<String, dynamic> toJson() => {
        'shop': shopId,
        'fulfillment_method': method.value,
        'meetup_note': meetupNote,
        'desired_at': desiredAt?.toUtc().toIso8601String(),
      };
}

class OrdersMeta {
  const OrdersMeta({required this.accountKind, required this.canBuy, required this.tabs});
  final String accountKind;
  final bool canBuy;
  final List<OrderRole> tabs;

  factory OrdersMeta.fromJson(Map<String, dynamic> j) => OrdersMeta(
        accountKind: j['account_kind'] as String,
        canBuy: j['can_buy'] as bool,
        tabs: ((j['tabs'] as List?) ?? const []).map((e) => OrderRole.parse(e as String)).toList(),
      );
}
