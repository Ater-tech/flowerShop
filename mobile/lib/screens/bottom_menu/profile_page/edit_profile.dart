import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mobile/models/profile_info/profile_model.dart';
import 'package:mobile/providers/profile_provider/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, required this.profile});
  final ProfileModel profile;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.profile.firstName);
  late final _lastName = TextEditingController(text: widget.profile.lastName);
  late final _phone = TextEditingController(text: widget.profile.phoneNumber ?? '');
  File? _avatar;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phone.text.trim();
    final error = await ref.read(profileControllerProvider.notifier).update(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          // Telefon faqat hali kiritilmagan bo'lsa yuboriladi (backend ham shuni talab qiladi)
          phoneNumber: !widget.profile.hasPhone && phone.isNotEmpty ? phone : null,
          avatar: _avatar,
        );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileControllerProvider);
    final p = widget.profile;

    ImageProvider? avatarImage;
    if (_avatar != null) {
      avatarImage = FileImage(_avatar!);
    } else if (p.avatar != null) {
      avatarImage = NetworkImage(p.avatar!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profilni tahrirlash')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: isSaving ? null : _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.camera_alt, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Ism'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Familiya'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              enabled: !p.hasPhone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefon raqam',
                hintText: '+998901234567',
                helperText: p.hasPhone ? "Telefon raqamni o'zgartirib bo'lmaydi" : null,
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (p.hasPhone || value.isEmpty) return null;
                return RegExp(r'^\+998\d{9}$').hasMatch(value)
                    ? null
                    : 'Format: +998901234567';
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}