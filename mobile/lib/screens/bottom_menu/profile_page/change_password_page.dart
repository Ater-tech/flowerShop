import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/providers/profile_provider/profile_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(profileControllerProvider.notifier).changePassword(
          oldPassword: _old.text,
          newPassword: _new.text,
        );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parol muvaffaqiyatli o'zgartirildi")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Parolni o'zgartirish")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _old,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Eski parol'),
              validator: (v) => (v == null || v.isEmpty) ? 'Eski parolni kiriting' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _new,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Yangi parol'),
              validator: (v) =>
                  (v == null || v.length < 8) ? 'Kamida 8 ta belgi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Yangi parolni tasdiqlang'),
              validator: (v) => v != _new.text ? 'Parollar mos kelmadi' : null,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Parolni o'zgartirish"),
            ),
          ],
        ),
      ),
    );
  }
}