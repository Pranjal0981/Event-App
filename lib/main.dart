import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:grocery_app/Providers/eventProvider.dart'; // Import EventProvider
import 'package:grocery_app/Auth/login_screen.dart';
import 'package:grocery_app/Auth/register_screen.dart';
import 'package:grocery_app/Auth/forget_screen.dart';
import 'package:grocery_app/Screen/home_screen.dart';
import 'package:grocery_app/Screen/bottom_nav.dart';
import 'package:grocery_app/Screen/Splash_Screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
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
        '/home': (context) => BottomNav(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
