import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/product_models/occasion_category_model.dart';

final occasionCategoryListProvider =
    FutureProvider<List<OccasionCategoryModel>>((ref) async {
  // keyin backend repository bilan almashtiriladi
  return [];
});