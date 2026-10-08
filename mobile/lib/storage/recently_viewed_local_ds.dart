import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:mobile/models/product_model.dart';

class RecentlyViewedLocalDataSource {
  static const _boxName = 'recently_viewed';
  static const _key = 'products';
  static const maxItems = 10;

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

  Future<List<ProductModel>> read() async {
    final box = await _getBox();
    final raw = box.get(_key, defaultValue: const <String>[]) as List;
    final result = <ProductModel>[];
    for (final item in raw.cast<String>()) {
      try {
        result.add(ProductModel.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (e) {
        // model o'zgargan bo'lsa eski yozuv butun ro'yxatni buzmasin
        debugPrint('[recent] skip broken item: $e');
      }
    }
    return result;
  }

  Future<void> write(List<ProductModel> items) async {
    final box = await _getBox();
    await box.put(_key, items.map((p) => jsonEncode(p.toJson())).toList());
  }
}