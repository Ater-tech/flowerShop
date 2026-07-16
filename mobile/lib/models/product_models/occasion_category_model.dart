class OccasionCategoryModel {
  final int id;
  final String title;
  final String imageUrl;

  OccasionCategoryModel({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory OccasionCategoryModel.fromJson(Map<String, dynamic> json) =>
      OccasionCategoryModel(
        id: json['id'] as int,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String,
      );
}