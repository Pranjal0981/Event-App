import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _currentUser;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get currentUser => _currentUser;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> registerUser(String name, String email, String phone, String password) async {
    final url = Uri.parse('http://192.168.9.187:3001/user/registerUser');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        await fetchCurrentUser();
        return responseBody['message'] ?? 'User registered successfully';
      } else {
        final responseBody = json.decode(response.body);
        return responseBody['message'] ?? 'Registration failed';
      }
    } catch (error) {
      return 'Error registering user: $error';
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.9.187:3001/user/currentUser'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentUser = responseData['user'];
        print(currentUser);
        await _saveAuthDataToPrefs(token, _currentUser!);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch current user');
      }
    } catch (error) {
      _currentUser = null;
      notifyListeners();
      throw Exception('Failed to fetch current user: $error');
    }
  }

  Future<void> _saveAuthDataToPrefs(String token, Map<String, dynamic> currentUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(currentUser)); // Save the user map as a JSON string
  }
}
