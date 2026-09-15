class SellerModel {
  final int id;
  final double ratingAvg;
  final bool isPremium;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;

  const SellerModel({
    required this.id,
    required this.ratingAvg,
    required this.isPremium,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as int,
      ratingAvg: double.parse(json['rating_avg'].toString()),
      isPremium: json['is_premium'] as bool? ?? false,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
