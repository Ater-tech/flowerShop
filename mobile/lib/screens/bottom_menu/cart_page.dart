import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends ConsumerStatefulWidget{
  const CartPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CartState();
  }
}

class _CartState extends ConsumerState<ConsumerStatefulWidget>{
  @override
  Widget build(BuildContext context) {
   return  Center(child: Text("Loading..."));
  }
}