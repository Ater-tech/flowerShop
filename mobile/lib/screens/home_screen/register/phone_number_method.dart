import 'package:flutter/material.dart';

TextFormField phoneNumberMethod(TextEditingController phoneNumberController) {
  return TextFormField(
    controller: phoneNumberController,
    keyboardType: TextInputType.number,
    maxLength: 7,
    decoration: InputDecoration(
      hintText: "Phone number ...",
      suffixIcon: Icon(Icons.phone, color: Colors.blue),
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
