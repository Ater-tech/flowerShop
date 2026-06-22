import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen/register/register_page.dart';
import 'email_method.dart';
import 'password_method.dart';
import 'other_method_sign_in.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LogInState();
  }
}

class _LogInState extends State<LogInPage> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool rememberMe = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF73AEF5),
                Color(0xFF61A4F1),
                Color(0xFF478DE0),
                Color(0xFF398AE5),
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            ),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: 40,
              vertical: 120,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  signInText(),
                  SizedBox(height: 30),
                  //email
                  emailMethod(email),
                  SizedBox(height: 10),

                  //password
                  passwordMethod(password),
                  forgotPassword(),

                  SizedBox(height: 40),
                  logIn(context),
                  SizedBox(height: 10),
                  withEmailSignIn(context),
                  otherMethodsSignUp(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Text signInText() {
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

  Row withEmailSignIn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account", style: TextStyle(color: Colors.white)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CounterPage()),
            );
          },
          child: Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  ElevatedButton logIn(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Text(
          "LOGIN",
          style: TextStyle(color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Row forgotPassword() {
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
                setState(() {
                  rememberMe = val!;
                });
              },
            ),
            Text("Remember Me", style: TextStyle(color: Colors.white)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Forgot Password?",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
