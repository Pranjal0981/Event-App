import 'package:flutter/material.dart';
import 'package:grocery_app/Auth/forget_screen.dart';
import 'package:grocery_app/Auth/register_screen.dart';
import 'package:grocery_app/Screen/bottom_nav.dart';
import 'Auth/login_screen.dart';
import 'Screen/Splash_Screen.dart';
import 'Screen/home_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.redAccent,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.redAccent,
          secondary: Colors.red,
        ),
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
      routes: {
        '/register': (context) => RegisterScreen(),
        '/forget-password': (context) => ForgetPasswordScreen(),
        '/home':(context)=>BottomNav()
      },
    );
  }
}
