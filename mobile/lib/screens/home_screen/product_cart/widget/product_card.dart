import 'package:flutter/material.dart';
import 'discount_badge.dart';
import 'original_badge.dart';
import 'rating_row.dart';
import 'package:mobile/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavouriteTap;
  final bool isFavouriteLoading;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavouriteTap,
    this.isFavouriteLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: .06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      "assets/photos/no_image.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _FavouriteButton(
                      isFavourited: product.isFavourited,
                      onTap: onFavouriteTap,
                    ),
                  ),
                  if (product.isOriginal)
                    const Positioned(top: 6, left: 6, child: OriginalBadge()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${product.price.toStringAsFixed(0)} so'm",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.discountPercent > 0) ...[
                        const SizedBox(width: 6),
                        DiscountBadge(percent: product.discountPercent),
                      ],
                    ],
                  ),
                  if (product.oldPrice != null)
                    Text(
                      "${product.oldPrice!.toStringAsFixed(0)} so'm",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  const SizedBox(height: 4),
                  RatingRow(
                    rating: product.ratingAvg,
                    reviewCount: product.reviewCount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  final bool isFavourited;
  final VoidCallback? onTap;

  const _FavouriteButton({required this.isFavourited, this.onTap});

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
        child: Icon(
          isFavourited ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: isFavourited ? Colors.red : Colors.black54,
        ),
      ),
    );
  }
}
