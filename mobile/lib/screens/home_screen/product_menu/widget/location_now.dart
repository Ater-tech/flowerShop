import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/providers/city_provider.dart';
import 'package:mobile/screens/home_screen/location/location_of_destination.dart';

class DeliveryLocationHeader extends ConsumerWidget {
  const DeliveryLocationHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCityAsync = ref.watch(selectedCityProvider);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LocationOfDestination()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.black87,
              size: 22,
            ),
            const SizedBox(width: 8),
            _CityNameText(selectedCityAsync: selectedCityAsync),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black54,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              'Qayerga yetkaziladi?',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: .5),
              ),              
            ),
          ],
        ),
      ),
    );
  }
}

class _CityNameText extends StatelessWidget {
  final AsyncValue selectedCityAsync;

  const _CityNameText({required this.selectedCityAsync});

  @override
  Widget build(BuildContext context) {
    return selectedCityAsync.when(
      data: (city) => Text(
        city?.name ?? 'Shahar tanlang',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      loading: () => const SizedBox(
        height: 16,
        width: 100,
        child: LinearProgressIndicator(
          minHeight: 2,
          color: Colors.black26,
          backgroundColor: Colors.transparent,
        ),
      ),
      error: (_, _) => const Text(
        'Shahar tanlang',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}
