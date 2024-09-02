import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/userProvider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.grey[850]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App logo or name
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 30.0),
                        child: Icon(
                          Icons.person_pin,
                          size: 100,
                          color: Colors.redAccent,
                        ),
                      ),
                      // Login card with modern design
                      Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black54,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Email input field
                              TextField(
                                controller: _emailController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.redAccent),
                                  prefixIcon: Icon(Icons.email_outlined, color: Colors.redAccent),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 16),
                              // Password input field with eye icon
                              TextField(
                                controller: _passwordController,
                                style: TextStyle(color: Colors.white),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.redAccent),
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.redAccent),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              // Login button with gradient background
                              userProvider.isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : Container(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            await userProvider.login(
                                              _emailController.text,
                                              _passwordController.text,
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Login Successful'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            Navigator.pushReplacementNamed(context, '/home');
                                          } catch (error) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Login Failed'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Login',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent, // Background color
                                          foregroundColor: Colors.white, // Text color
                                          padding: EdgeInsets.symmetric(vertical: 16.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          shadowColor: Colors.black54,
                                          elevation: 8,
                                        ),
                                      ),
                                    ),
                              SizedBox(height: 16),
                              // Forgot password
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/forget-password');
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Register link
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "Don't have an account? Register",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
