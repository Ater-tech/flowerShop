import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/screens/crud_product/save_flower.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddState();
  }
}

class _AddState extends State<StatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shopController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceConrtoller = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime? created;
  bool aviable = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Flower name"),
                validator: validatorNotEmNotNull,
              ),
              TextFormField(
                controller: shopController,
                decoration: InputDecoration(labelText: "Shop name"),
                validator: validatorNotEmNotNull,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Descriptions..."),
                validator: validatorNotEmNotNull,
              ),
              TextFormField(
                controller: priceConrtoller,
                decoration: InputDecoration(labelText: "Price..."),
                validator: validatorNotEmNotNull,
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location..."),
                validator: validatorNotEmNotNull,
              ),
              SwitchListTile(
                title: Text("Available"),
                value: aviable,
                onChanged: (val) {
                  setState(() {
                    aviable = val;
                  });
                },
              ),
              ListTile(
                title: Text(
                  created == null
                      ? "Please  choose the date"
                      : "${created!.year}-${created!.month}-${created!.day}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      created = pickedDate;
                    });
                  }
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
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  // if (_selectedImage == null) {
                  //   return;
                  // }
                  if (created == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Choose date ...")));
                    return;
                  }
                  if (_selectedImage == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("CHoose image ...")));
                    return;
                  }

                  try {
                    await FlowerWriteRepository().saveFlower(
                      name: nameController.text,
                      shopName: shopController.text,
                      description: descriptionController.text,
                      aviable: aviable,
                      image: _selectedImage!,
                      location: locationController.text,
                      price: double.parse(priceConrtoller.text),
                    );

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Successfully done!")),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error $e")));
                  }
                },
                child: Text("Save"),
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
}
