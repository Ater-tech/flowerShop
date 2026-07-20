class BannerModel {
  final int id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final int order;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      linkUrl: json['link_url'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }
}