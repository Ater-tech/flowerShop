import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen/register/password_reg_ex.dart';

TextFormField passwordMethod(TextEditingController password) {
  return TextFormField(
    controller: password,
    keyboardType: TextInputType.visiblePassword,
    obscureText: true,
    decoration: InputDecoration(
      hintText: "password",
      suffixIcon: Icon(Icons.lock, color: Colors.blue),
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
    validator: (value) {
      if (value == null) return;
      if (regExPassword(value)) return;
      return;
    },
  );
}
