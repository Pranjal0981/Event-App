import 'dart:convert';
import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token; // Getter for token

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> signup(String name, String email, String phoneNumber, String password) async {
    try {
      setLoading(true);

      final response = await http.post(
        Uri.parse('http://192.168.43.255:3001/user/registerUser'),
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Signup successful');
      } else {
        throw Exception('Failed to sign up');
      }
    } catch (error) {
      print('Failed to sign up: $error');
      throw Exception('Failed to sign up: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      setLoading(true);

      final Map<String, dynamic> formData = {
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('http://192.168.243.187:3001/user/login'),
        body: json.encode(formData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        _token = token;

        // Save token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Call to fetch the current user data
        await fetchCurrentUser();
      } else {
        throw Exception('Failed to log in');
      }
    } catch (error) {
      throw Exception('Failed to log in: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final token = _token ?? await _getTokenFromPrefs();
      if (token == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.243.187:3001/user/currentUser'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentUser = responseData['user']; // Update with correct response parsing
        print(_currentUser);
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
    await prefs.setString('currentUser', json.encode(currentUser));
  }

  Future<String?> _getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> autoLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userData = prefs.getString('currentUser');

  if (token != null) {
    _token = token;
    if (userData != null) {
      _currentUser = json.decode(userData);
    }
    notifyListeners();
  } else {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}
Future<bool> uploadEvent({
  required String title,
  required String description,
  required String location,
  required DateTime date,
  required double price,
  required File image,
}) async {
  final uri = Uri.parse('http://192.168.243.187:3001/user/upload-event'); // Replace with your API URL
  final token = _token ?? await _getTokenFromPrefs(); // Get the token

  final request = http.MultipartRequest('POST', uri)
    ..fields['title'] = title
    ..fields['description'] = description
    ..fields['location'] = location
    ..fields['date'] = date.toIso8601String()
    ..fields['price'] = price.toString()
    ..files.add(await http.MultipartFile.fromPath('image', image.path));

  // Add the Authorization header with the Bearer token
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  try {
    final response = await request.send();
    if (response.statusCode == 201) {
      return true; // Success
    } else {
      return false; // Failure
    }
  } catch (e) {
    print('Error during event upload: $e');
    return false; // Failure
  }
}

}
