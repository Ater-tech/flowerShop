import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/models/city_model/city_model.dart';
// import 'package:mobile/server/location_service.dart';

final cityListProvider = FutureProvider<List<CityModel>>((ref) {
  return ref.watch(cityRepositoryProvider).fetchCities(forceRefresh: true);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCitiesProvider = Provider<AsyncValue<List<CityModel>>>((ref) {
  final citiesAsync = ref.watch(cityListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return citiesAsync.whenData((cities) {
    if (query.isEmpty) return cities;
    return cities.where((c) => c.name.toLowerCase().contains(query)).toList();
  });
});

class SelectedCityNotifier extends AsyncNotifier<CityModel?> {
  @override
  Future<CityModel?> build() async {
    debugPrint("Build boshlandi");
    final repo = ref.watch(cityRepositoryProvider);

    final saved = await repo.getSelectedCity();
    debugPrint("getselectedCity tugadi -> $saved");
    if (saved != null) return saved;

    final cities = await ref.watch(cityListProvider.future);
    return cities.isNotEmpty ? cities.first : null;
  }

  Future<void> selectCity(CityModel city) async {
    debugPrint('1) selectCity boshlandi: ${city.name}');
    final previousState = state;
    state = AsyncValue.data(city);
    try {
      final repo = ref.read(cityRepositoryProvider);
      await repo.saveSelectedCityLocally(city);
      debugPrint('2) SAVE SELECTED: ${city.name}');
      await repo.sendSelectedCityToBackend(city);
      debugPrint('3) SEND TO BACKEDN: ${city.name}');
    } catch (e, stack) {
      state = previousState;
      state = AsyncValue.error(e, stack);
    }
  }
}

final selectedCityProvider =
    AsyncNotifierProvider<SelectedCityNotifier, CityModel?>(
      SelectedCityNotifier.new,
    );
