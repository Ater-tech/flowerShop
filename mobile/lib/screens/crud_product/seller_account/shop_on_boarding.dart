import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/shop_model.dart';
import 'package:mobile/providers/shop_provider.dart';
import 'package:mobile/screens/crud_product/city_drop_down.dart';
import 'package:mobile/screens/crud_product/seller_account/location_picker.dart';

class ShopOnboardingPage extends ConsumerWidget {
  const ShopOnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(shopFormControllerProvider);
    final controller = ref.read(shopFormControllerProvider.notifier);

    ref.listen(shopFormControllerProvider, (previous, next) {
      // submit() natijasini alohida kuzatish shart emas — bu yerda
      // faqat submit tugagach navigatsiya qilamiz (pastda tugma ichida)
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Do'kon ma'lumotlari")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<ShopType>(
              segments: const [
                ButtonSegment(value: ShopType.personal, label: Text('Shaxsiy')),
                ButtonSegment(
                  value: ShopType.business,
                  label: Text("Rasmiy do'kon"),
                ),
              ],
              selected: {formState.shopType},
              onSelectionChanged: (s) => controller.setShopType(s.first),
            ),
            if (formState.shopType == ShopType.business)
              TextFormField(
                decoration: const InputDecoration(labelText: "Do'kon nomi"),
                onChanged: controller.setName,
              ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Manzil'),
              onChanged: controller.setAddress,
            ),
            CityDropdownField(
              selectedCityId: formState.cityId,
              onChanged: (id) {
                if(id != null){
                  controller.setCity(id);
                }
              },
            ), // mavjud city provider'ingizga ulanadi
            LocationPickerField(
              onLocationPicked: (lat, lng) => controller.setLocation(lat, lng),
            ), // xarita/geolocation
            FilledButton(
              onPressed: formState.isSubmitting
                  ? null
                  : () async {
                      final result = await controller.submit();
                      if (!context.mounted) return;
                      switch (result) {
                        case Success():
                          Navigator.pop(context);
                        case Error(:final failure):
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(failure.message)),
                          );
                      }
                    },
              child: formState.isSubmitting
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                  : const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}
