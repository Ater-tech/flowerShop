// product_card.dart ichida _FavouriteButton'ni yangilaymiz
import 'package:flutter/material.dart';

class FavouriteButton extends StatelessWidget {
  final bool isFavourited;
  final bool isLoading;
  final VoidCallback? onTap;

  const FavouriteButton({
    super.key,
    required this.isFavourited,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isFavourited ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isFavourited ? Colors.red : Colors.black54,
              ),
      ),
    );
  }
}
