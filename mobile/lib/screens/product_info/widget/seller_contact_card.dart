import 'package:flutter/material.dart';
import 'package:mobile/models/seller_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerContactCard extends StatelessWidget {
  const SellerContactCard({super.key, required this.seller});
  final SellerModel seller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: seller.avatarUrl != null
                ? NetworkImage(seller.avatarUrl!)
                : null,
            child: seller.avatarUrl == null
                ? const Icon(Icons.person, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        seller.fullName ?? 'Sotuvchi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (seller.isPremium) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 16, color: Colors.blue),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      seller.ratingAvg.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (seller.phoneNumber != null)
            IconButton.filledTonal(
              icon: const Icon(Icons.call_outlined),
              onPressed: () => _launchPhoneCall(seller.phoneNumber!),
            ),
        ],
      ),
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
