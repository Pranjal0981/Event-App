import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grocery_app/Auth/login_screen.dart';
import 'package:grocery_app/Screen/animated_svg_text.dart';
import 'package:grocery_app/Screen/home_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For managing authentication state

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(seconds: 5), // Adjust the duration to 5 seconds
      vsync: this,
    );

    _animation = IntTween(begin: 0, end: 12).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    _redirectTimer = Timer(Duration(seconds: 5), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    // Check if user is logged in
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom event-related icon
              Icon(
                Icons.event, // Event icon from Material Icons
                size: 120,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              // Animated text
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(200, 60), // Adjust the size as needed
                    painter: AnimatedTextPainter(
                      text: 'Event Master',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      currentLetterIndex: _animation.value,
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Text(
                'Your Gateway to Unforgettable Experiences!',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Plan, Book, Enjoy - All in One Place',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _redirectTimer?.cancel();
    super.dispose();
  }
}
