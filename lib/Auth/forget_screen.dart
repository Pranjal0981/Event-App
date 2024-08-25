import 'package:flutter/material.dart';
import 'package:grocery_app/Auth/verify_otp.dart';
import 'package:http/http.dart' as http;

class DotLoader extends StatefulWidget {
  @override
  _DotLoaderState createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      upperBound: 1,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(Colors.redAccent, _animation),
          SizedBox(width: 10),
          _buildDot(Colors.redAccent, _animation),
          SizedBox(width: 10),
          _buildDot(Colors.redAccent, _animation),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class RequestOtpScreen extends StatefulWidget {
  @override
  _RequestOtpScreenState createState() => _RequestOtpScreenState();
}

class _RequestOtpScreenState extends State<RequestOtpScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // Add this variable to track loading state

  Future<void> _requestOtp() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      // Show error message if email is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true before making the request
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.243.187:3001/user/request-otp'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        // Show a success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('OTP Sent'),
            content: Text('An OTP has been sent to $email. Please check your email to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerifyOtpScreen(email: email),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error message if OTP request fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to request OTP')),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after request completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request OTP'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? DotLoader() // Use the custom loader
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Forgot your password?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Enter your email to receive an OTP for password reset.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.redAccent),
                      prefixIcon: Icon(Icons.email, color: Colors.redAccent),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestOtp,
                    child: Text('Request OTP'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 15)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(8),
                      shadowColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.5)),
                      minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 50)), // Full width and height
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
