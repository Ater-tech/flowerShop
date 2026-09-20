import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/product_model.dart'; 

/// "Oxirgi qidirilganlar" — foydalanuvchi ochgan mahsulotlar (lokal).
/// Implementatsiya: mavjud recentlyViewed (Hive CE) kodingizga ulanadi.
abstract interface class RecentProductsRepository {
  Future<Result<List<ProductModel>>> getRecent({int limit = 10});
  Future<Result<void>> add(ProductModel product);
}
