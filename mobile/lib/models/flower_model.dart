class FlowerModel {
  final int id;
  String name;
  String shopName;
  String image;
  String description;
  String location;
  double price;
  bool available;
  DateTime created;
  bool fav;
  FlowerModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.image,
    required this.description,
    required this.location,
    required this.price,
    required this.available,
    required this.created,
    required this.fav,
  });
  
  factory FlowerModel.fromJSON(Map<String, dynamic> data) {
  return FlowerModel(
    id: data['id'] as int,
    name: (data['name'] ?? '') as String,
    shopName: (data['shop_name'] ?? '') as String,
    image: (data['image_url'] ?? '') as String,          // ← image_url
    description: (data['description'] ?? '') as String,
    location: (data['city_name'] ?? '') as String,       // ← city_name
    price: double.tryParse('${data['price']}') ?? 0,
    available: (data['available'] as bool?) ?? true,
    created: DateTime.tryParse('${data['created_at']}') ?? DateTime.now(), // ← created_at
    fav: (data['is_favourited'] as bool?) ?? false,      // ← is_favourited
  );
}
//   factory FlowerModel.fromJSON(Map<String, dynamic> data) {
//   return FlowerModel(
//     id: data['id'] as int,
//     name: (data['name'] ?? '') as String,
//     shopName: (data['shop_name'] ?? '') as String,
//     image: (data['image'] ?? '') as String,
//     description: (data['description'] ?? '') as String,
//     location: (data['location'] ?? '') as String,
//     price: double.tryParse('${data['price']}') ?? 0,
//     available: (data['available'] as bool?) ?? true,
//     created: DateTime.tryParse('${data['created']}') ?? DateTime.now(),
//     fav: (data['is_favourite'] as bool?) ?? false,
//   );
// }  
}
