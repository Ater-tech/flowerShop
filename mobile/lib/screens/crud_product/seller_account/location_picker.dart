import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerField extends StatefulWidget {
  const LocationPickerField({super.key, required this.onLocationPicked});
  final void Function(double latitude, double longitude) onLocationPicked;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  bool _isLoading = false;
  double? _lat;
  double? _lng;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Joylashuv ruxsati kerak')),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
      widget.onLocationPicked(position.latitude, position.longitude);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _getCurrentLocation,
          icon: _isLoading
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location),
          label: const Text('Joriy joylashuvni olish'),
        ),
        if (_lat != null && _lng != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Lat: ${_lat!.toStringAsFixed(5)}, Lng: ${_lng!.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}