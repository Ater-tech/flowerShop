import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget{
 final Color color;
 const ForgotPassword({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return  TextButton(
        onPressed: () {},
        child: Text("Forgot Password?", style: TextStyle(color: color)),
      );
  }
}
