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
      appBar: AppBar(
        title: Text("Welcome to Flower online SHOP"),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: password,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
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
    );
  }
}
