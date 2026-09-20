import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/search_providers.dart';

class SearchHistorySection extends ConsumerWidget {
  const SearchHistorySection({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(searchHistoryControllerProvider).value ?? const <String>[];
    if (items.isEmpty) return const SizedBox.shrink(); // tarix bo'sh — joy egallamaydi

    final controller = ref.read(searchHistoryControllerProvider.notifier);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Qidiruv tarixi',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: controller.clear, child: const Text('Tozalash')),
            ],
          ),
          for (final query in items)
            InkWell(
              onTap: () => onSelected(query),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(child: Text(query, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () => controller.remove(query),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}