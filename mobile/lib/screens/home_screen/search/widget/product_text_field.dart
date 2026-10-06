import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/product_provider/product_search_providers.dart';
import 'package:mobile/providers/search_providers.dart';

class ProductTextField extends ConsumerWidget {
  final TextEditingController controller;
  const ProductTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: Colors.black87),
      onChanged: (value) {
        // Debounce oqimini ishga tushiradi, tarixga YOZMAYDI
        ref.read(rawSearchInputProvider.notifier).state = value;
      },
      onSubmitted: (value) {
        final q = value.trim();
        if (q.isEmpty) return;
        ref.read(searchHistoryControllerProvider.notifier).add(q);
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, v, _) => v.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    controller.clear();
                    ref.read(rawSearchInputProvider.notifier).state = '';
                  },
                ),
        ),
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
