import 'package:flutter/material.dart';

class EmailMethod extends StatelessWidget{
  final TextEditingController email;
  const EmailMethod({super.key, required this.email});

  @override
  Widget build(BuildContext context){
    return  TextFormField(
    controller: email,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      hintText: "Email ...",
      suffixIcon: Icon(Icons.email, color: Colors.blue),
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
}
