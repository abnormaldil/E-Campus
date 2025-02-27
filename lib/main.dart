import 'package:ecampus/lending.dart';
import 'package:ecampus/login.dart';
import 'package:ecampus/register.dart';
import 'package:ecampus/route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecampus/home.dart';
import 'package:ecampus/splash.dart';
import 'package:ecampus/temporary.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAgjDoLAlRI-dmsvGEIAIwjAbMcukznaHc",
      appId: "1:618311522744:web:cd6c9db96c9c6bebfc174d",
      messagingSenderId: "618311522744",
      projectId: "rit24safaai",
    ),
  );



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      routes: {
        // '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterScreen(),

      },
    );
  }
}