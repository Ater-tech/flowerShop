import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/models/city_model/city_model.dart';
import 'package:mobile/repository/city_repository.dart';
import 'package:mobile/server/location_service.dart';
import 'package:mobile/storage/token_storage.dart';

final cityRepositoryProvider = Provider((ref) => CityRepository(dio: Dio(), storage: TokenStorage()));

final cityListProvider = FutureProvider<List<CityModel>>((ref) {
  return ref.watch(cityRepositoryProvider).fetchCities();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCitiesProvider = Provider<AsyncValue<List<CityModel>>>((ref) {
  final citiesAsync = ref.watch(cityListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return citiesAsync.whenData((cities) {
    if (query.isEmpty) return cities;
    return cities
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  });
});

class SelectedCityNotifier extends AsyncNotifier<CityModel?> {
  @override
  Future<CityModel?> build() async {
    final repo = ref.read(cityRepositoryProvider);

    final saved = await repo.getSelectedCity();
    if (saved != null) return saved;

    final cityName = await LocationService().getCurrentCityName();
    final cities = await repo.fetchCities();

    if (cityName != null) {
      final matched = cities.where(
        (c) => c.name.toLowerCase() == cityName.toLowerCase(),
      );
      if (matched.isNotEmpty) return matched.first;
    }

    return cities.isNotEmpty ? cities.first : null;
  }

  Future<void> selectCity(CityModel city) async {
    state = AsyncValue.data(city);
    final repo = ref.read(cityRepositoryProvider);
    await repo.saveSelectedCityLocally(city);
    await repo.sendSelectedCityToBackend(city);
  }
}

final selectedCityProvider =
    AsyncNotifierProvider<SelectedCityNotifier, CityModel?>(
  SelectedCityNotifier.new,
);