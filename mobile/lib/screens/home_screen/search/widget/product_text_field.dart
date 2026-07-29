import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ProductTextField extends ConsumerWidget{
  final TextEditingController controller;
  const ProductTextField({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context, WidgetRef ref){
    return TextField(            
            controller: controller,
            style: const TextStyle(color: Colors.black87),
            onChanged: (value) {},
            decoration: InputDecoration(
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.black54,),
              hintText: "Qanday guldasta qidirmoqdasiz",
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: .4)),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            );
  }
}