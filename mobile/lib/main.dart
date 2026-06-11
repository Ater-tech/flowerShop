import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(FlowerApp());
}

class FlowerApp extends StatelessWidget {
  const FlowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
