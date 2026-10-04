import 'package:mobile/error_handler/error_result.dart'; 
import 'package:mobile/models/product_model.dart'; 

/// Qidiruv sahifasidagi "kashf etish" bloklari.
/// Tartib va reklama mantiqi backend'da — klient faqat ko'rsatadi.
abstract interface class SearchDiscoverRepository {
  /// Faqat pul to'lagan (faol reklama) mahsulotlar.
  Future<Result<List<ProductModel>>> getRecommended({int limit = 10});

  /// Eng ko'p qidirilgan / yuqori reytingli; reklama to'laganlar birinchi.
  Future<Result<List<ProductModel>>> getPopular({int limit = 10});
}
