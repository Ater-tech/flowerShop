import 'package:flutter/material.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/screens/product_info/delevery_info_section.dart';
import 'package:mobile/screens/product_info/description_section.dart';
import 'package:mobile/screens/product_info/reviews_preview_section.dart';
import 'package:mobile/screens/product_info/seller_stat.dart';
import 'package:mobile/screens/product_info/smilar_shop_boutique.dart';
import 'package:mobile/screens/product_info/weekly_sales_section.dart';

class ProductInfoContainer extends StatelessWidget {
  const ProductInfoContainer({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SellerStatsRow(shop: product.shop),
          const Divider(height: 32),
          WeeklySalesSection(productId: product.id),
          const SizedBox(height: 20),
          SimilarShopBouquetsSection(shopId: product.shop.id!),
          const SizedBox(height: 20),
          DescriptionSection(description: product.description),
          const SizedBox(height: 20),
          DeliveryInfoSection(shop: product.shop),
          const SizedBox(height: 20),
          ReviewsPreviewSection(productId: product.id),
          const SizedBox(height: 20),
          SellerContactCard(seller: product.shop.seller),
          const SizedBox(height: 24),
          RecommendedProductsSection(excludeProductId: product.id),
        ],
      ),
    );
  }
}
