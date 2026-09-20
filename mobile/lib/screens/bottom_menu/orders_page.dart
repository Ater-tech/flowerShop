import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersPage extends ConsumerStatefulWidget{
  const OrdersPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _OrderState();
  }
}

class _OrderState extends ConsumerState<ConsumerStatefulWidget>{
  @override
  Widget build(BuildContext context) {
   return  Center(child: Text("Loading..."));
  }
}