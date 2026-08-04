// screens/product/widgets/city_dropdown_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/city_provider.dart';

class CityDropdownField extends ConsumerWidget {
  final int? selectedCityId;
  final ValueChanged<int?> onChanged;

  const CityDropdownField({
    super.key,
    required this.selectedCityId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(
      cityListProvider,
    ); // sizdagi mavjud provider nomi

    return citiesAsync.when(
      data: (cities) => DropdownButtonFormField<int>(
        initialValue: selectedCityId,
        decoration: const InputDecoration(labelText: "Shahar"),
        items: cities
            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Shaharni tanlang" : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text("Shaharlar yuklanmadi: $e"),
    );
  }
}
