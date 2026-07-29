import 'package:flutter/material.dart';

class RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const RatingRow({super.key, required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    if (reviewCount == 0) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(Icons.star, size: 13, color: Colors.amber),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          "($reviewCount)",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}