import 'package:mobile/models/seller_model.dart';

enum ShopType { personal, business }

extension ShopTypeX on ShopType {
  String get apiValue => this == ShopType.personal ? 'personal' : 'business';

  static ShopType fromApi(String value) =>
      value == 'business' ? ShopType.business : ShopType.personal;
}

class ShopModel {
  final int? id;
  final ShopType shopType;
  final String name;
  final String address;
  final int cityId;
  final String? cityName;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final int totalSold;
  final int productCount;
  final SellerModel? seller;
  const ShopModel({
    this.id,
    required this.shopType,
    required this.name,
    required this.address,
    required this.cityId,
    this.cityName,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.totalSold = 0,
    this.productCount = 0,
    this.seller,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as int?,
      shopType: ShopTypeX.fromApi(json['shop_type'] as String),
      name: json['name'] as String,
      address: json['address'] as String,
      cityId: json['city'] as int,
      cityName: json['city_name'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      totalSold: json['total_sold'] as int? ?? 0,
      productCount: json['product_count'] as int? ?? 0,
      seller: json['seller'] != null
        ?SellerModel.fromJson(json['seller'] as Map<String, dynamic>)
        :null,
    );
  }

  /// (API'ga yuborish uchun toJson() ishlatiladi.)
  Map<String, dynamic> toJson() {
    return {
      'shop_type': shopType.apiValue,
      if (shopType == ShopType.business) 'name': name,
      'address': address,
      'city': cityId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  /// Lokal keshlash uchun: fromJson'ning aniq teskarisi.
  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'shop_type': shopType.apiValue, // enum emas, String
      'name': name,
      'address': address,
      'city': cityId,
      'city_name': cityName,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'total_sold': totalSold,
      'product_count': productCount,
      // seller ataylab yozilmaydi (nullable): kartada kerak emas,
      // SellerModel.toJson() yozishni talab qilmasligi uchun
    };
  }
}