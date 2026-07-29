class ProductModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int? cityId;
  final String? cityName;

  final bool available;
  final DateTime createdAt;
  final DateTime updatedAt;

  final double price;
  final double? oldPrice;
  final int discountPercent;

  final int sellerId;
  final String sellerName;
  final bool sellerIsPremium;

  final double ratingAvg;
  final int reviewCount;
  final int soldCount;
  final int viewCount;
  final bool isOriginal;
  final bool isFavourited;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cityId,
    required this.cityName,
    required this.available,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.sellerId,
    required this.sellerName,
    required this.sellerIsPremium,
    required this.ratingAvg,
    required this.reviewCount,
    required this.soldCount,
    required this.viewCount,
    required this.isOriginal,
    required this.isFavourited,
  });

  factory ProductModel.fromJson(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] as int,
      name: _checkString(data['name']),
      description: _checkString(data['description']),
      imageUrl: data['image_url'] ?? "assets/photos/no_image.jpg",
      cityId: data['city'] as int?,
      cityName: data['city_name'] as String?,
      available: data['available'] ?? true,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      price: _parseDouble(data['price']),
      oldPrice: data['old_price'] == null ? null : _parseDouble(data['old_price']),
      discountPercent: data['discount_percent'] ?? 0,
      sellerId: data['seller'] as int,
      sellerName: _checkString(data['seller_name']),
      sellerIsPremium: data['seller_is_premium'] ?? false,
      ratingAvg: _parseDouble(data['rating_avg']),
      reviewCount: data['review_count'] ?? 0,
      soldCount: data['sold_count'] ?? 0,
      viewCount: data['view_count'] ?? 0,
      isOriginal: data['is_original'] ?? false,
      isFavourited: data['is_favourited'] ?? false,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _checkString(dynamic value) {
    if (value is String) return value;
    if (value is num) return "$value";
    return "No data";
  }
}