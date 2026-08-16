class SellerModel {
  final int id;
  final double ratingAvg;
  final bool isPremium;

  const SellerModel({
    required this.id,
    required this.ratingAvg,
    required this.isPremium,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as int,
      ratingAvg: double.parse(json['rating_avg'].toString()),
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }
}