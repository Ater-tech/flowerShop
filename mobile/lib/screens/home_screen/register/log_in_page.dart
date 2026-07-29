import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/controllers/auth_controllers.dart';
import 'package:mobile/screens/home_screen/product_menu/main_page.dart';
import 'package:mobile/screens/home_screen/register/methods/log_in_button.dart';
import 'package:mobile/screens/home_screen/register/methods/remember_me_method.dart';
import 'methods/email_method.dart';
import 'methods/password_method.dart';
import 'methods/other_method_sign_in.dart';
import 'methods/forgot_password.dart';
import 'methods/sign_in.dart';
import 'methods/with_email_sign_in.dart';

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
            child: ListView(
              children: [
                SignIn(),
                SizedBox(height: 30),
                //email
                EmailMethod(email: email),
                SizedBox(height: 10),
                //password
                passwordMethod(password),
                Row(
                  children: [
                    RememberMeMethod(color: Colors.white),
                    ForgotPassword(color: Colors.white),
                  ],
                ),
                SizedBox(height: 40),
                LogInButton(authState:authState, email: email, password: password),
                SizedBox(height: 10),
                withEmailSignIn(context),
                otherMethodsSignUp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}