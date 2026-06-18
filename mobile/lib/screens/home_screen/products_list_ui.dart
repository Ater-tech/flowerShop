import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/flower_model.dart';

SliverList productList({
  required List<FlowerModel> flowerList,
  required Set<int> favItems,
  required Function(int) onTap,
}) {
  return SliverList.builder(
    itemBuilder: (context, index) {
      final flower = flowerList[index];
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.3,
        width: double.infinity,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: CachedNetworkImage(
                imageUrl: flower.image,
                errorWidget: (context, url, error) =>
                    Image.asset("assets/photos/no_image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white.withValues(alpha: 0.5),
                child: ListTile(
                  title: Text(flower.name),
                  trailing: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Added to Favourite")),
                      );
                      onTap(index);
                    },
                    icon: Icon(Icons.favorite),
                    color: favItems.contains(index) ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
    itemCount: flowerList.length,
  );
}
