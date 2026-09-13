class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.userFullName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final int id;
  final int productId;
  final String userFullName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      productId: json['product'] as int,
      userFullName: json['user_full_name'] as String? ?? '',
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}