import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/city_model/city_model.dart';
import 'package:mobile/auth/providers/city_provider.dart';

class LocationOfDestination extends ConsumerWidget {
  const LocationOfDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCities = ref.watch(filteredCitiesProvider);
    final selectedCityAsync = ref.watch(selectedCityProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            _SearchField(),
            const SizedBox(height: 12),
            Expanded(
              child: filteredCities.when(
                data: (cities) => _CityList(
                  cities: cities,
                  selectedCity: selectedCityAsync.value,
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Xatolik: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Text(
            'Choose your city:',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).state = value,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          hintText: 'Shaharni qidirish',
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: .4)),
          filled: true,
          fillColor: Colors.black.withValues(alpha: .06),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CityList extends ConsumerWidget {
  final List<CityModel> cities;
  final CityModel? selectedCity;

  const _CityList({required this.cities, required this.selectedCity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cities.isEmpty) {
      return const Center(child: Text('Shahar topilmadi'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final isSelected = selectedCity?.id == city.id;

        return InkWell(
          onTap: () {
            ref.read(selectedCityProvider.notifier).selectCity(city);
            Navigator.of(context).pop(city);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: .08),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    city.name,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.check,
                        color: Color(0xFF7ED957), size: 20),
                  ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.black54, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}