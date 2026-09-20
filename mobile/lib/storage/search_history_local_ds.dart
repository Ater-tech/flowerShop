import 'package:hive_ce/hive.dart';

class SearchHistoryLocalDataSource {
  static const _boxName = 'search_history';
  static const _key = 'queries';
  static const maxItems = 5;

  // Box bir marta ochiladi: bir vaqtning o'zida ikki joydan openBox
  // qilish Hive'da navbatda qotib qolishga olib keladi.
  Future<Box<dynamic>>? _boxFuture;
  Future<Box<dynamic>> get _box => _boxFuture ??= Hive.openBox<dynamic>(_boxName);

  Future<List<String>> read() async {
    final box = await _box;
    final raw = box.get(_key, defaultValue: const <String>[]) as List;
    return List<String>.of(raw.cast<String>()); // o'zgartirsa bo'ladigan nusxa
  }

  Future<void> write(List<String> items) async {
    final box = await _box;
    await box.put(_key, items);
  }
}
