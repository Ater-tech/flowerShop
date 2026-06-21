import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen/register/register_page.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          padding: EdgeInsetsGeometry.symmetric(horizontal: 40, vertical: 120),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign in",
                  style: TextStyle(
                    fontFamily: 'OpenSams',
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),

                //username
                userName(),
                SizedBox(height: 10),

                //email
                emailMethod(),
                SizedBox(height: 10),

                //password
                passwordMethod(),
                Container(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(onPressed: () {}, child: Text("Log in")),
                SizedBox(height: 10),
                Text("If you don't have an account yet, just click this:"),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CounterPage()),
                    );
                  },
                  child: Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField passwordMethod() {
    return TextFormField(
      controller: password,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.lock, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
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

  TextFormField emailMethod() {
    return TextFormField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.email, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
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

  TextFormField userName() {
    return TextFormField(
      controller: username,
      keyboardType: TextInputType.text,
      cursorColor: Colors.blueAccent,
      decoration: InputDecoration(
        hintText: "User name ...",
        suffixIcon: Icon(Icons.person, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
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
