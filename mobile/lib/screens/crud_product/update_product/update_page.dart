import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/product_model.dart';
import 'package:mobile/providers/product_provider/product_detail_provider.dart';

class UpdatePage extends ConsumerStatefulWidget{
  final ProductModel product;
  const UpdatePage({super.key, required this.product});

  @override
  ConsumerState<UpdatePage> createState()=> _UpdatePageState();
}

class _UpdatePageState extends ConsumerState<UpdatePage>{
  @override
  Widget build(BuildContext context){
    final ref.read(productDetailProvider);
    return Scaffold(

    );
  }
}