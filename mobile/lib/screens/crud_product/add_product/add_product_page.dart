import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/error_handler/failure.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models/shop_model.dart';
import 'package:mobile/controllers/product_controller.dart';

class AddProductPage extends ConsumerStatefulWidget {
  final  ShopModel shop;
  const AddProductPage({super.key, required this.shop});

  @override
  ConsumerState<AddProductPage> createState() {
    return _AddState();
  }
}

class _AddState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceConrtoller = TextEditingController();
  // final TextEditingController _oldPriceConrtoller = TextEditingController();
  bool available = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late bool isLoading;
  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Flower name"),
                validator: validatorNotEmNotNull,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Descriptions..."),
                validator: validatorNotEmNotNull,
              ),
              TextFormField(
                controller: _priceConrtoller,
                decoration: InputDecoration(labelText: "Price..."),
                validator: validatorNotEmNotNull,
              ),
              SwitchListTile(
                title: Text("Available"),
                value: available,
                onChanged: (val) {
                  setState(() {
                    available = val;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    _selectedImage = File(image.path);
                  }
                },
                child: Text("Choose image"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
  onPressed: isLoading
      ? null
      : () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          if (_selectedImage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Choose image ...")),
            );
            return;
          }

          setState(() => isLoading = true);

          final result = await ref
              .read(productControllerProvider.notifier)
              .add(
                name: _nameController.text,
                description: _descriptionController.text,
                shopId: widget.shop.id!,
                available: available,
                image: _selectedImage!,
                price: double.parse(_priceConrtoller.text),
              );

          if (!context.mounted) return;
          setState(() => isLoading = false);

          switch (result) {
            case Success():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Successfully done!")),
              );
              Navigator.pop(context, true);

            case Error(failure: PaymentRequiredFailure failure):
              _showPaymentRequiredDialog(context, failure);

            case Error(failure: ValidationFailure failure):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Xatolik: ${(failure).errors}")),
              );

            case Error(:final failure):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Xatolik: ${failure.runtimeType}")),
              );
          }
        },
  child: isLoading
      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
      : const Text("Save"),
),
            ],
          ),
        ),
      ),
    );
  }

  String? validatorNotEmNotNull(dynamic val) {
    if (val == null || val.trim().isEmpty) {
      return "Required field!";
    }
    return null;
  }

  void _showPaymentRequiredDialog(BuildContext context, PaymentRequiredFailure failure) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Limit tugadi"),
      content: Text(failure.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Bekor qilish"),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            // Payme/Click integratsiyasi ulanganda shu yerga yo'naltiriladi
          },
          child: Text("To'lash (${failure.pricePerProduct} so'm)"),
        ),
      ],
    ),
  );
}
  // int get _calculatedDiscount {
  //   final price = double.tryParse(_priceConrtoller.text);
  //   final oldPrice = double.tryParse(_oldPriceConrtoller.text);
  //   if (price == null || oldPrice == null || oldPrice <= price) return 0;
  //   return (((oldPrice - price) / oldPrice) * 100).round();
  // }
}
