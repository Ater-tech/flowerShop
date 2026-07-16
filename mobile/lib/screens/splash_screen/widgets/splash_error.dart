import 'package:flutter/material.dart';

class SplashError extends StatelessWidget {
  final VoidCallback onRetry;
  const SplashError({super.key, required this.onRetry});
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline_rounded, size: 64, color: Colors.black),
        const SizedBox(height: 16),
        Text(
          'Nimadir xato ketdi',
          style: TextStyle(color: Colors.black26, fontSize: 16),
        ),
        const SizedBox(height: 20),
        FilledButton.tonal(
          onPressed: onRetry,
          child: const Text('Qayta urinish'),
        ),
      ],
    );
  }
}