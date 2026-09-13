import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/review_model.dart';
import 'package:mobile/providers/review_provider.dart';
class ReviewsPreviewSection extends ConsumerWidget {
  const ReviewsPreviewSection({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sharhlar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        switch (reviewsAsync) {
          AsyncData(:final value) when value.isEmpty =>
            const Text('Hozircha sharhlar yo\'q'),
          AsyncData(:final value) => SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _ReviewCard(review: value[i]),
              ),
            ),
          AsyncError() => const Text('Sharhlarni yuklab bo\'lmadi'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.userFullName, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Row(
                children: List.generate(5, (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}