import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/providers/seller_provider.dart';

class SellerOnboardingPage extends ConsumerStatefulWidget {
  const SellerOnboardingPage({super.key});

  @override
  ConsumerState<SellerOnboardingPage> createState() => _SellerOnboardingPageState();
}

class _SellerOnboardingPageState extends ConsumerState<SellerOnboardingPage> {
  bool _isSubmitting = false;

  Future<void> _becomeSeller() async {
    setState(() => _isSubmitting = true);
    final result = await ref.read(sellerRepositoryProvider).becomeSeller();
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    switch (result) {
      case Success():
        ref.invalidate(sellerProfileProvider);
        Navigator.pop(context);
      case Error(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Mahsulot qo\'shish uchun avval sotuvchi sifatida ro\'yxatdan o\'ting.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _becomeSeller,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Sotuvchi bo\'lish'),
            ),
          ],
        ),
      );
  }
}