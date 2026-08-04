import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/product_repo_providers.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

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
  final TextEditingController _oldPriceConrtoller = TextEditingController();
  bool available = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late bool isLoading;
  int? _selectedCityId;
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
                            SnackBar(content: Text("CHoose image ...")),
                          );
                          return;
                        }
                        if (_selectedCityId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Shahar tanlang')),
                          );
                          return;
                        }
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          await ref
                              .read(productRepositoryProvider)
                              .saveFlower(
                                name: _nameController.text,
                                cityId: _selectedCityId!,
                                description: _descriptionController.text,
                                available: available,
                                image: _selectedImage!,
                                price: double.parse(_priceConrtoller.text),
                              );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Successfully done!")),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Error $e")));
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text("Save"),
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

  int get _calculatedDiscount {
    final price = double.tryParse(_priceConrtoller.text);
    final oldPrice = double.tryParse(_oldPriceConrtoller.text);
    if (price == null || oldPrice == null || oldPrice <= price) return 0;
    return (((oldPrice - price) / oldPrice) * 100).round();
  }
}
