class TokenModel {
  final String access;
  final String refresh;

  TokenModel({required this.access, required this.refresh});

  factory TokenModel.fromJson(Map<String, dynamic> data) {
    return TokenModel(access: data["access"], refresh: data["refresh"]);
  }
}
