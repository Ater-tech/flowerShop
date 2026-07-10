import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/providers/product_providers.dart';
import 'package:mobile/screens/home_screen/products_list_ui.dart';
import 'package:mobile/screens/crud_product/add_product_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _ProductState();
}

class _ProductState extends ConsumerState<MainPage> {
  Set<int> favItems = {};
  @override
  Widget build(BuildContext context) {
  final products = ref.watch(productControllerProvider);
    return Scaffold(
      body: products.when(
        data: (list){
          return
          CustomScrollView(
        slivers: [
          SliverAppBar.large(
            actions: [
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductPage()),
                  );
                  if(result){ref.invalidate(productControllerProvider);} 
                },
                icon: Icon(Icons.add_outlined),
              ),
              IconButton(
                onPressed: () => ref.refresh(productControllerProvider),
                icon: Icon(Icons.refresh),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Flowers   Buy&Sell",
                style: TextStyle(color: Colors.white),
              ),
              background: Image.asset(
                "assets/photos/appbar.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          productList(
            flowerList: list, 
            favItems: favItems, 
            onTap: (id) {
            setState(() {
              if (favItems.contains(id)) {
                favItems.remove(id);
              } else {
                favItems.add(id);
              }
            });
          },),
        ],
      );
          }, 
          error: (e, s) => Center(
            child: Column(
              children: [Text("Error"), Text(e.toString())],
            ),
          ), 
          loading: () => Center(child: CircularProgressIndicator.adaptive())
          )
    );
  }

}
