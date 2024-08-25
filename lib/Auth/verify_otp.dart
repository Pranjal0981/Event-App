import 'dart:convert'; // Import this for json.encode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  VerifyOtpScreen({required this.email});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> _verifyOtp() async {
    final otp = _otpController.text;
    final newPassword = _newPasswordController.text;

    if (otp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter OTP and new password')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.243.187:3001/user/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': widget.email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset successful')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP or failed to reset password')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                labelStyle: TextStyle(color: Colors.redAccent),
                prefixIcon: Icon(Icons.lock, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.black.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.redAccent),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.black.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: Text('Verify OTP'),
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
