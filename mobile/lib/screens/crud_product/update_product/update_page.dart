// edit_product_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/controllers/edit_product_controller.dart';
import 'package:mobile/models/product_model.dart';

class EditProductPage extends ConsumerStatefulWidget {
  const EditProductPage({super.key, required this.product});
  final ProductModel product;

  @override
  ConsumerState<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product.name);
  late final _priceCtrl = TextEditingController(
    text: widget.product.price.toString(),
  );
  late final _descCtrl = TextEditingController(
    text: widget.product.description,
  );
  File? _newImage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x != null) setState(() => _newImage = File(x.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final failure = await ref
        .read(editProductControllerProvider.notifier)
        .save(
          id: widget.product.id,
          name: _nameCtrl.text.trim(),
          price: num.parse(_priceCtrl.text.trim()),
          description: _descCtrl.text.trim(),
          newImage: _newImage,
        );
    if (!mounted) return;

    if (failure != null) {
      _snack(failure.message, error: true);
      return;
    }
    _snack('Mahsulot yangilandi');
    Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(ctx).colorScheme.error,
          size: 40,
        ),
        title: const Text("Mahsulotni o'chirasizmi?"),
        content: Text(
          '"${widget.product.name}" butunlay o\'chiriladi. '
          'Bu amalni qaytarib bo\'lmaydi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ha, o'chirish"),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final failure = await ref
        .read(editProductControllerProvider.notifier)
        .delete(widget.product.id);
    if (!mounted) return;

    if (failure != null) {
      _snack(failure.message, error: true);
      return;
    }
    _snack("Mahsulot o'chirildi");
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProductControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !state.isBusy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mahsulotni tahrirlash')),
        body: AbsorbPointer(
          absorbing: state.isBusy,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Rasm ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _newImage != null
                                ? Image.file(_newImage!, fit: BoxFit.cover)
                                : Image.network(
                                    widget.product.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: CircleAvatar(
                                  child: Icon(Icons.edit, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Maydonlar ---
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nomi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nomini kiriting'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Narxi (so'm)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = num.tryParse(v?.trim() ?? '');
                      return (n == null || n <= 0)
                          ? "To'g'ri narx kiriting"
                          : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Tavsif',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Saqlash ---
                  FilledButton(
                    onPressed: state.isBusy ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Saqlash'),
                  ),

                  // --- Alohida "xavfli zona" ---
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.errorContainer.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.error.withValues(alpha: .5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.dangerous_outlined, color: cs.error),
                            const SizedBox(width: 8),
                            Text(
                              'Xavfli zona',
                              style: TextStyle(
                                color: cs.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Mahsulotni o'chirsangiz, uni qaytarib bo'lmaydi.",
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: state.isBusy ? null : _confirmDelete,
                          icon: state.isDeleting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          label: const Text("Mahsulotni o'chirish"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                            side: BorderSide(color: cs.error),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
