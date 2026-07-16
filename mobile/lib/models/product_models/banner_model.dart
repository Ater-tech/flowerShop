class BannerModel {
  final int id;
  final String imageUrl;
  final String? deepLink;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.deepLink,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as int,
        imageUrl: json['image_url'] as String,
        deepLink: json['deep_link'] as String?,
      );
}