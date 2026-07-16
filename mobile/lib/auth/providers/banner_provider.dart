import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/product_models/banner_model.dart';
// import '../repositories/banner_repository.dart'; // keyin ulanadi

final bannerListProvider = FutureProvider<List<BannerModel>>((ref) async {
  // hozircha placeholder, keyin repository orqali backenddan olinadi
  return [];
});