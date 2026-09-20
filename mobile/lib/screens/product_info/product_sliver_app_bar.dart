import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/providers/favourite_providers.dart';

class ProductSliverAppBar extends ConsumerWidget {
  const ProductSliverAppBar({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 380,
      leading: _CircleIconButton(
        icon: Icons.arrow_back, 
        onTap: ()=> Navigator.pop(context),
        ),
      actions: [
        _CircleIconButton(
          icon: product.isFavourited ? Icons.favorite : Icons.favorite_border,
          onTap: () => ref.read(favouriteControllerProvider.notifier).toggle(product.id),
        ),
        const _CircleIconButton(icon: Icons.share_outlined),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // AppBar collapse bo'lganda avtomatik fade-in bilan chiqadi
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 56),
        background: Hero(
          tag: 'product-image-${product.id}',
          child: PageView.builder(
            itemCount: product.imageUrl.length,
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: product.imageUrl[index],
              fit: BoxFit.cover,
              placeholder: (context, url){
                return const Center(
                  child: CircularProgressIndicator(),
                );                
              },
              errorWidget: (context, url, error){
                return Image.asset('assets/photos/no_image.png',
                fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: .85),
        child: IconButton(icon: Icon(icon, color: Colors.black87), onPressed: onTap),
      ),
    );
  }
}