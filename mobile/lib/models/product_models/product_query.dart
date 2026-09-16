// domain/models/product_query.dart
class ProductQuery {
  final String search;
  final int? cityId;
  final int? shopId;
  final int? excludeId;
  final String ordering; // masalan "-rating_avg", "price"
  final bool premiumSellersOnly;

  const ProductQuery({
    this.search = "",
    this.cityId,
    this.shopId,
    this.excludeId,
    this.ordering = "-created_at",
    this.premiumSellersOnly = false,
  });

  ProductQuery copyWith({
    String? search,
    int? cityId,
    int? shopId,
    int? excludeId,
    String? ordering,
    bool? premiumSellersOnly,
  }) {
    return ProductQuery(
      search: search ?? this.search,
      cityId: cityId ?? this.cityId,
      shopId: shopId ?? this.shopId,
      excludeId: excludeId ?? this.excludeId,
      ordering: ordering ?? this.ordering,
      premiumSellersOnly: premiumSellersOnly ?? this.premiumSellersOnly,
    );
  }

  
  Map<String, dynamic> toQueryParams() {
    return {
      if (search.isNotEmpty) "search": search,
      if (cityId != null) "city": cityId,
      if (shopId != null) "shop": shopId,
      if (excludeId != null) "exclude": excludeId,
      "ordering": ordering,
      if (premiumSellersOnly) "premium_sellers": "true",
    };
  }
}
