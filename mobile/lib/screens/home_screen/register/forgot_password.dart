import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

Row forgotPassword(StateProvider remProvider, bool rememberMe) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: rememberMe,
            activeColor: Colors.white,
            // checkColor: Colors.white,
            side: BorderSide(color: Colors.white),
            onChanged: (val) {  
                                         
              // setState(() {
              //   rememberMe = val!;
              // });
            },
          ),
          Text("Remember Me", style: TextStyle(color: Colors.white)),
        ],
      ),
      TextButton(
        onPressed: () {},
        child: Text("Forgot Password?", style: TextStyle(color: Colors.white)),
      ),
    ],
  );
}
