import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/flower_model.dart';
import 'package:mobile/server/flower_api_server.dart';
import 'auth_providers.dart';

final productApiProvider = Provider<FlowerApiServer>(
  (ref){
    return FlowerApiServer(ref.read(apiProvider));
  }
);
final productControllerProvider = FutureProvider<List<FlowerModel>>(
  (ref) async{
    return await ref.read(productApiProvider).getData();
  }
);
