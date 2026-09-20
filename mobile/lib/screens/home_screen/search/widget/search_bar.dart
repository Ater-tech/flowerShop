import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/product_search_providers.dart';
import 'package:mobile/screens/home_screen/search/widget/product_text_field.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBarWidget> {
  late final TextEditingController nameController;
  
  
  @override
  void initState(){
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose(){
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(rawSearchInputProvider, (prev, next) {
    if (nameController.text != next) {           // tsikl bo'lmasligi uchun tekshiruv
      nameController.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length), // kursor oxirida
      );
    }
  });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        // alignment: AlignmentGeometry.center, 
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.black.withValues(alpha: 0.6)),
          ),
          Expanded(child: ProductTextField(controller: nameController),
            ),
        ],
      ),
    );
  }
}
