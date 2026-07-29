import 'package:flutter/material.dart';

class DiscountBadge extends StatelessWidget {
  final int percent;

  const DiscountBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1EA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "-$percent%",
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE31C5F),
        ),
      ),
    );
  }
}