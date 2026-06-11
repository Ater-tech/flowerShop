import 'package:flutter/material.dart';
import 'package:mobile/models/flower_model.dart';
import 'package:mobile/screens/home_screen/products_list_ui.dart';
import 'package:mobile/server/flower_api_server.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
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
          FutureBuilder(
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
                      children: [
                        Text("Snap error"),
                        Text(snap.error.toString()),
                      ],
                    ),
                  ),
                );
              }
              final data = snap.data ?? [];
              return productList(data);
            },
          ),
        ],
      ),
    );
  }
}
