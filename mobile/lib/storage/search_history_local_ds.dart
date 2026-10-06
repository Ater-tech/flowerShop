import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class SearchHistoryLocalDataSource {
  static const _boxName = 'search_history';
  static const _key = 'queries';
  static const maxItems = 5;

  Future<Box<dynamic>>? _opening;

  Future<Box<dynamic>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<dynamic>(_boxName);
    try {
      return await (_opening ??= Hive.openBox<dynamic>(_boxName));
    } catch (e) {
      _opening = null; // xatoli Future keshda qolmasin
      rethrow;
    }
  }

  Future<List<String>> read() async {
    final box = await _getBox();
    final raw = box.get(_key, defaultValue: const <String>[]) as List;
    return List<String>.of(raw.cast<String>());
  }

  Future<void> write(List<String> items) async {
    final box = await _getBox();
    await box.put(_key, items);
    debugPrint('[history] saved: $items');
  }
}
