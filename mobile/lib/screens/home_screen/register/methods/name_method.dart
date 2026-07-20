import 'package:flutter/material.dart';

TextFormField nameMethod(TextEditingController nameController, String name) {
  return TextFormField(
    controller: nameController,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      hintText: "$name ...",
      suffixIcon: Icon(Icons.person, color: Colors.blue),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black54),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
