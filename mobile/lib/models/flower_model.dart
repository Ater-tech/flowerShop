class FlowerModel {
  String name;
  String shopName;
  String image;
  String description;
  String location;
  double price;
  bool aviable;
  DateTime created;

  FlowerModel({
    required this.name,
    required this.shopName,
    required this.image,
    required this.description,
    required this.location,
    required this.price,
    required this.aviable,
    required this.created,
  });

  factory FlowerModel.fromJSON(Map<String, dynamic> data) {
    return FlowerModel(
      name: data['name'],
      shopName: data['shop_name'],
      image: data['image'],
      description: data['description'],
      location: data['location'],
      price: double.parse(data['price']),
      aviable: data['aviable'],
      // aviable: bool.parse(data['aviable']),
      created: DateTime.parse(data['created']),
    );
  }
}
