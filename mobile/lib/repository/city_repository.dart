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

  CityRepository({
    required this.dio, 
    required this.storage});
    


  Future<List<CityModel>> fetchCities({bool forceRefresh = false}) async {
    final box = await Hive.openBox<CityModel>(_citiesBox);

    if (!forceRefresh && box.isNotEmpty) {
      return box.values.toList();
    }

    try {
      debugPrint("City list chaqirishga urunish");
      final response = await dio.get(
        ApiEndpoints.citiesList);
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
    final box = await Hive.openBox<CityModel>(_selectedCityBox);
    return box.get(_selectedCityKey);
  }

  Future<void> saveSelectedCityLocally(CityModel city) async {
    final box = await Hive.openBox<CityModel>(_selectedCityBox);
    await box.put(_selectedCityKey, city);
  }

  Future<void> sendSelectedCityToBackend(CityModel city) async {
    try {
      final response = await dio.post(
        ApiEndpoints.userCity,
        data: {'city_id': city.id},
      );
      debugPrint("Shahar backendda saqlandi: ${response.statusCode}");
    } catch (e, stack) {
      // xatolikni loglash yoki qayta urinish logikasi shu yerga
      debugPrint("Backendga yuborishda xatolik: $e");
      debugPrint("Stacktrace: $stack");
    }
  }
}