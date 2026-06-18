import 'package:flutter/material.dart';
import 'package:mobile/models/flower_model.dart';
import 'package:mobile/screens/home_screen/products_list_ui.dart';
import 'package:mobile/server/flower_api_server.dart';
import 'package:mobile/screens/crud_product/add_product_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<int> favItems = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductPage()),
                  );
                },
                icon: Icon(Icons.add_outlined),
              ),
              IconButton(
                onPressed: () {
                  listProducts();
                  setState(() {});
                },
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
          listProducts(),
        ],
      ),
    );
  }

  FutureBuilder<List<FlowerModel>> listProducts() {
    return FutureBuilder(
      future: FlowerApiServer.getData(),
      builder: (context, AsyncSnapshot<List<FlowerModel>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (snap.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                children: [Text("Snap error"), Text(snap.error.toString())],
              ),
            ),
          );
        }
        final data = snap.data ?? [];
        return productList(
          flowerList: data,
          favItems: favItems,
          onTap: (id) {
            setState(() {
              if (favItems.contains(id)) {
                favItems.remove(id);
              } else {
                favItems.add(id);
              }
            });
          },
        );
      },
    );
  }
}
