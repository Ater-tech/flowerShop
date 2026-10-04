class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.avatar,
    this.cityId,
    this.cityName,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? avatar;
  final int? cityId;
  final String? cityName;

  /// Ism bo'sh bo'lsa (register faqat username so'raydi) username ko'rsatiladi.
  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  bool get hasPhone => phoneNumber != null && phoneNumber!.isNotEmpty;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      cityId: json['city'] as int?,
      cityName: json['city_name'] as String?,
    );
  }
}