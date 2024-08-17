import 'package:flutter/material.dart';
import 'package:grocery_app/Auth/login_screen.dart'; // Adjust the import based on your file structure

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Adjust the duration as needed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your initial screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black,
          child: Center(
            child: Icon(
              Icons.shopping_cart,
              size: 100,
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }
}
