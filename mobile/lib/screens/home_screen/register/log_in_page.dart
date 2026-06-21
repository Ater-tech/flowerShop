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
  bool rememberMe = false;
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
                forgotPassword(),

                SizedBox(height: 40),
                logIn(context),
                SizedBox(height: 10),
                withEmailSignIn(context),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("--OR--", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    Text("Sign in with", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(6),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 10,
                                ),
                              ],

                              // image: DecorationImage(
                              //   image: AssetImage("assets/brands/facebook.png"),
                              //   // fit: BoxFit.cover,
                              // ),
                            ),
                            child: ClipRRect(
                              child: Image.asset("assets/brands/facebook.png"),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(6),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                              // image: DecorationImage(
                              //   image: AssetImage("assets/brands/google.png"),
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                            child: ClipRRect(
                              child: Image.asset("assets/brands/google.png"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  TextFormField passwordMethod() {
    return TextFormField(
      controller: password,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "password",
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
        hintText: "Email ...",
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
