import 'package:mobile/error_handler/error_result.dart';

/// Qidiruv tarixi (faqat matn so'rovlar). Har bir o'zgartiruvchi metod
/// yangilangan ro'yxatni qaytaradi — controller qayta o'qimaydi.
abstract interface class SearchHistoryRepository {
  Future<Result<List<String>>> getHistory();
  Future<Result<List<String>>> add(String query);
  Future<Result<List<String>>> remove(String query);
  Future<Result<List<String>>> clear();
}
