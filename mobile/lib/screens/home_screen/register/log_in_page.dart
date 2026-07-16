import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/controllers/auth_controllers.dart';
import 'package:mobile/screens/home_screen/product_menu/main_page.dart';
import 'email_method.dart';
import 'password_method.dart';
import 'other_method_sign_in.dart';
import 'forgot_password.dart';
import 'sign_in.dart';

class LogInPage extends ConsumerStatefulWidget {
  const LogInPage({super.key});

  @override
  ConsumerState<LogInPage> createState() {
    return _LogInState();
  }
}

class _LogInState extends ConsumerState<LogInPage> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void dispose(){
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Xatolik: $error"))
          );
        },
        data: (data) {
          if(previous is AsyncLoading){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));
          }
        }
      );
    });
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          height: height,
          width: width,
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
              horizontal: width * 0.028,
              vertical: height * 0.12,
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
                  forgotPassword(ref, Colors.white),
                  SizedBox(height: 40),
                  logIn(context, authState),
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

  ElevatedButton logIn(BuildContext context, AsyncValue<void> authState) {
    return ElevatedButton(
      onPressed: authState.isLoading
          ? null
          : () async {
            await ref
                  .read(authControllerProvider.notifier)
                  .login(email.text, password.text);
                 
            },
      child: authState.isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Text(
                "LOGIN",
                style: TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
