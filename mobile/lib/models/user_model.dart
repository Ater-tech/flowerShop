class UserModel {
  String name;
  
  UserModel({
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(name: json["username"]);
  }
}