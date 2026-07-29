import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/auth/controllers/auth_controllers.dart';
import 'package:mobile/screens/home_screen/register/methods/email_method.dart';
import 'package:mobile/screens/home_screen/register/methods/forgot_password.dart';
import 'package:mobile/screens/home_screen/register/log_in_page.dart';
import 'package:mobile/screens/home_screen/register/methods/name_method.dart';
import 'package:mobile/screens/home_screen/register/methods/password_method.dart';
import 'package:mobile/screens/home_screen/register/methods/phone_number_method.dart';
import 'package:mobile/utils/responsive.dart';

final counterProvider = StateProvider<int>((ref) => 0);

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<RegisterPage> {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController userNameController = TextEditingController();
    TextEditingController eMailController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);    
    final height = context.screenHeight;
    final width = context.screenWidth;
    ref.listen(authControllerProvider, (previous, next){
      next.whenOrNull(
        data: (_){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LogInPage()));
        },
        error: (error, stackTrace){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Xatolik: $error"))
          );
        }
      );
    });
    return Scaffold(
      backgroundColor: Color(0xF8F9F8F0),
      appBar: (AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      )),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive(mobile: 16, tablet: 32, desktop: 64),
          vertical: 16
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Text(
                "Let's create your account",
                style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),              
              ),
              SizedBox(height: height*0.02,),
              nameMethod(firstNameController, "First Name"),
              SizedBox(height: height*0.01,),
              nameMethod(lastNameController, "Last Name"),            
              SizedBox(height: height*0.01,),
              nameMethod(userNameController, "User Name"),
              SizedBox(height: height*0.01,),
              EmailMethod(email: eMailController),
              SizedBox(height: height*0.01,),
              phoneNumberMethod(phoneNumberController),
              SizedBox(height: height*0.01,),
              passwordMethod(passwordController),
              SizedBox(height: height*0.014,),
              ForgotPassword(color: Colors.black),
              SizedBox(height: height*0.014,),
              createAccount(authController, context),
            ],
          ),
        ),
      ),
      
    );
  }

  ElevatedButton createAccount(AsyncValue<void> authController, BuildContext context){
    return ElevatedButton(
      onPressed: authController.isLoading
      ?null
      :(){
        ref.read(authControllerProvider.notifier)
        .register(
          userNameController.text,
          passwordController.text,
        );
      }, 
      child: authController.isLoading
      ? CircularProgressIndicator.adaptive()
      : Text(
      "Create Account", 
      style: TextStyle(color: Colors.blue), 
      textAlign: TextAlign.center,));
  }
}
