import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/server/flower_api_server.dart';
import 'repo_providers.dart';
// import '../repositories/product_repository.dart'; // keyin ulanadi

final productApiProvider = Provider<FlowerApiServer>(
  (ref){
    return FlowerApiServer(ref.read(apiProvider));
  }
);
final productControllerProvider = FutureProvider<List<ProductModel>>(
  (ref) async{
    return await ref.read(productApiProvider).getData();
  }
);
// final productListProvider = FutureProvider<List<FlowerModel>>((ref) async {
//   keyin repository orqali backenddan olinadi
//   return [];
// });