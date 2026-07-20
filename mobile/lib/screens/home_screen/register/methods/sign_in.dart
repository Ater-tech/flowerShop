 import 'package:flutter/material.dart';

class SignIn extends StatelessWidget{
  const SignIn({super.key});

@override
Widget build(BuildContext context){
  return Text(
      "Sign in",
      style: TextStyle(
        fontFamily: 'OpenSams',
        fontSize: 30,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
}
}

