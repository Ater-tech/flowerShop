import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/flower_model.dart';
import 'package:mobile/providers/favourite_providers.dart';
class FavouritesPage extends ConsumerWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favouritesListProvider);
    final pending = ref.watch(favouritePendingIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sevimlilar')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(favouritesListProvider),
            child: const Text('Xatolik. Qayta urinish'),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(favouritesListProvider.future),
          child: items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 160),
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Center(child: Text("Hali sevimli mahsulotlar yo'q")),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final f = items[i];
                    return _FavouriteTile(
                      flower: f,
                      busy: pending.contains(f.id),
                      onRemove: () => ref
                          .read(favouriteControllerProvider.notifier)
                          .toggle(f.id),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _FavouriteTile extends StatelessWidget {
  final FlowerModel flower;
  final bool busy;
  final VoidCallback onRemove;

  const _FavouriteTile({
    required this.flower,
    required this.busy,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Image.network(flower.image, width: 96, height: 96, fit: BoxFit.cover),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flower.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(flower.shopName, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text("${flower.price.toStringAsFixed(0)} so'm"),
              ],
            ),
          ),
          IconButton(
            onPressed: busy ? null : onRemove,
            icon: const Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),
    );
  }
}