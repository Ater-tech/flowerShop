import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_ce/hive.dart';
import 'package:mobile/models/city_model/city_model.dart';
import 'package:mobile/server/api_endpoints.dart';
import 'package:mobile/storage/token_storage.dart';

class CityRepository {
  final Dio dio;
  final TokenStorage storage;

  static const String _citiesBox = 'cities_box';
  static const String _selectedCityBox = 'selected_city_box';
  static const String _selectedCityKey = 'selected_city';

  CityRepository({required this.dio, required this.storage});

  Future<List<CityModel>> fetchCities({bool forceRefresh = false}) async {
    final box = await Hive.openBox<CityModel>(_citiesBox);

    if (!forceRefresh && box.isNotEmpty) {
      return box.values.toList();
    }

    try {
      debugPrint("City list chaqirishga urunish");
      final response = await dio.get(ApiEndpoints.citiesList);
      if (response.statusCode == 200) {
        final cities = (response.data as List)
            .map((e) => CityModel.fromJson(e))
            .toList();
        await box.clear();
        await box.addAll(cities);
        return cities;
      }
    } catch (e, stack) {
      // backend ishlamasa keshdagi malumot bilan davom etiladi
      debugPrint("xatolik city listda: $e\n/$stack");
    }

    return box.values.toList();
  }

  Future<CityModel?> getSelectedCity() async {
    try {
      final box = await Hive.openBox<CityModel>(_selectedCityBox);
      final cached = box.get(_selectedCityKey);
    //backend request
    try {
      debugPrint("DATA kutilmoqda!");
      final response = await dio.get(ApiEndpoints.userCity);
      debugPrint("DATA KELDI: ${response.data}");
      final cityData = response.data['city'];
      if (response.statusCode == 200 && cityData != null) {
        final cityModel = CityModel(id: cityData['id'], name: cityData['city']);
        await box.put(_selectedCityKey, cityModel);
        return cityModel;
      }
      return cached;
    } catch (e, stack) {
      debugPrint("backenddan city olishda xatolik $e\n$stack");
      return cached;
    }
} catch(e, stack){
  debugPrint("$e/n$stack");
  return null;
}  
}

  Future<void> saveSelectedCityLocally(CityModel city) async {
    try {
      final box = await Hive.openBox<CityModel>(_selectedCityBox);
      await box.put(_selectedCityKey, city.copyWith());
    } catch (e, stack) {
      debugPrint("Xatolik save sity to hive:\n$e\n$stack");
    }
  }

  Future<void> sendSelectedCityToBackend(CityModel city) async {
    try {
      final response = await dio.post(
        ApiEndpoints.userCity,
        data: {'id': city.id, 'name': city.name},
      );
      debugPrint("Shahar backendda saqlandi: ${response.statusCode}");
    } catch (e, stack) {
      // xatolikni loglash yoki qayta urinish logikasi shu yerga
      debugPrint("Backendga yuborishda xatolik: $e");
      debugPrint("Stacktrace: $stack");
    }
  }
}
