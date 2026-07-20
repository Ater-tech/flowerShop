import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/providers/repo_providers.dart';

Row forgotPassword(WidgetRef ref, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            checkColor: color,
            // activeColor: Colors.transparent,
            fillColor: WidgetStateProperty.all(Colors.transparent),
            value: ref.watch(rememberMeProvider),            
            side: WidgetStateBorderSide.resolveWith((states) => BorderSide(color: color)),
            onChanged: (val) {  
             ref.read(rememberMeProvider.notifier).state = val!;
            },
          ),
          Text("Remember Me", style: TextStyle(color: color)),
        ],
      ),
      TextButton(
        onPressed: () {},
        child: Text("Forgot Password?", style: TextStyle(color: color)),
      ),
    ],
  );
}
