enum OrderRole {
  buying,
  selling;

  static OrderRole parse(String v) => v == 'selling' ? OrderRole.selling : OrderRole.buying;
}

enum OrderStatus {
  newOrder('new', 'Yangi'),
  accepted('accepted', 'Qabul qilindi'),
  completed('completed', 'Bajarildi'),
  rejected('rejected', 'Rad etildi'),
  cancelled('cancelled', 'Bekor qilindi'),
  expired('expired', "Muddati o'tdi");

  const OrderStatus(this.value, this.label);
  final String value;
  final String label;

  static OrderStatus parse(String v) =>
      values.firstWhere((e) => e.value == v, orElse: () => OrderStatus.newOrder);
}

enum FulfillmentMethod {
  pickup('pickup', 'Borib olish'),
  taxi('taxi', 'Taxi orqali'),
  sellerDelivery('seller_delivery', 'Sotuvchi yetkazadi'),
  meetup('meetup', 'Kelishilgan joyda');

  const FulfillmentMethod(this.value, this.label);
  final String value;
  final String label;

  static FulfillmentMethod parse(String v) =>
      values.firstWhere((e) => e.value == v, orElse: () => FulfillmentMethod.pickup);

  static FulfillmentMethod? tryParse(String v) {
    for (final m in values) {
      if (m.value == v) return m;
    }
    return null;
  }
}

/// Backend `stage` maydoni: bitta holat, xaridor va sotuvchi uchun turlicha nom.
enum OrderStage {
  pending('pending'),
  incoming('incoming'),
  pickupInProgress('pickup_in_progress'),
  agreed('agreed'),
  archived('archived');

  const OrderStage(this.value);
  final String value;

  static OrderStage parse(String v) =>
      values.firstWhere((e) => e.value == v, orElse: () => OrderStage.pending);
}

enum OrderAction {
  accept('accept'),
  reject('reject'),
  cancel('cancel'),
  complete('complete');

  const OrderAction(this.value);
  final String value;

  static OrderAction? tryParse(String v) {
    for (final a in values) {
      if (a.value == v) return a;
    }
    return null;
  }
}
