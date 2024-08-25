import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  List<Map<String, dynamic>> _events = [];
  List<String> _favoriteEventIds = [];
  List<String> get favoriteEventIds => _favoriteEventIds;
  Map<String, dynamic>? _currentEvent;
 List<dynamic> _myEvents = [];
  List<dynamic> get myEvents => _myEvents;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  List<Map<String, dynamic>> get events => _events;
  Map<String, dynamic>? get currentEvent => _currentEvent;

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
        _currentUser = responseData['user'];
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

    Future<void> fetchEvents() async {
      try {
        setLoading(true);

        final token = _token ?? await _getTokenFromPrefs();
        if (token == null) {
          throw Exception('No token found');
        }

        final response = await http.get(
          Uri.parse('http://192.168.243.187:3001/user/getEvents'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          _events = List<Map<String, dynamic>>.from(responseData['events']);

    
        } else {
          throw Exception('Failed to fetch events');
        }
      } catch (error) {
        print('Failed to fetch events: $error');
        _events = [];
      } finally {
        setLoading(false);
        notifyListeners();
      }
    }

 Future<void> fetchFavoriteEvents() async {
  try {
    final token = _token ?? await _getTokenFromPrefs();
    if (token == null) {
      throw Exception('No token found');
    }

    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('currentUser');
    final user = json.decode(userString ?? '{}');
    final userId = user['_id'];

    final response = await http.get(
      Uri.parse('http://192.168.243.187:3001/user/getFavoriteEvents?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Access the favoriteEvents key and cast it to List<dynamic>
      final favoriteEvents = responseData['favoriteEvents'] as List<dynamic>;

      // Extract event IDs of favorites
      _favoriteEventIds = favoriteEvents
          .map((item) => item['_id'].toString())
          .toList();

      // Update _events with event details from the response
      _events = favoriteEvents.map((item) {
        return {
          '_id': item['_id'].toString(),
          'title': item['title'],
          'description': item['description'],
          'location': item['location'],
          'date': item['date'],
          'image': item['image']['url'], // Assuming you need the URL of the image
          // Add other fields as needed
        };
      }).toList();

      notifyListeners();
    } else {
      throw Exception('Failed to fetch favorite events');
    }
  } catch (error) {
    print('Failed to fetch favorite events: $error');
  }
}

  Future<void> toggleFavorite(String eventId) async {
    try {
      final token = _token ?? await _getTokenFromPrefs();
      if (token == null) {
        throw Exception('No token found');
      }

      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('currentUser');
      final user = json.decode(userString ?? '{}');
      final userId = user['_id'];

      final response = await http.post(
        Uri.parse('http://192.168.243.187:3001/user/toggle-favorite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'eventId': eventId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final isFavorite = responseData['isFavorite'];

        // Update the local event list based on the response
        _events = _events.map((event) {
          if (event['_id'] == eventId) {
            return {
              ...event,
              'isFavorite': isFavorite,
            };
          }
          return event;
        }).toList();

        // Update favorite event IDs
        if (isFavorite) {
          _favoriteEventIds.add(eventId);
        } else {
          _favoriteEventIds.remove(eventId);
        }

        notifyListeners();
      } else {
        throw Exception('Failed to toggle favorite status');
      }
    } catch (error) {
      print('Failed to toggle favorite: $error');
    }
  }

  Future<bool> uploadEvent({
    required String title,
    required String description,
    required String location,
    required String? eventType,
    required DateTime date,
    required double price,
    required File image,
  }) async {
    final uri = Uri.parse('http://192.168.243.187:3001/user/upload-event');
    final token = _token ?? await _getTokenFromPrefs();
    if (token == null) {
      throw Exception('No token found');
    }

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['location'] = location
      ..fields['eventType'] = eventType ?? ''
      ..fields['date'] = date.toIso8601String()
      ..fields['price'] = price.toString()
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = json.decode(responseData);

        if (result['success']) {
          return true;
        } else {
          throw Exception('Failed to upload event');
        }
      } else {
        throw Exception('Failed to upload event');
      }
    } catch (error) {
      print('Error uploading event: $error');
      return false;
    }
  }

Future<void> fetchEventById(String eventId) async {
  if (_currentEvent != null && _currentEvent!['_id'] == eventId) {
    // Event is already fetched
    return;
  }

  _isLoading = true;
  notifyListeners();

  try {
    final response = await http.get(Uri.parse('http://192.168.243.187:3001/user/getEvent/$eventId'));
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print('Response body: $responseBody'); // Debug response
      if (responseBody['success'] == true) {
        _currentEvent = responseBody['data']; // Access 'data' field
        print('Current Event: $_currentEvent'); // Debug _currentEvent
      } else {
        throw Exception('Failed to load event');
      }
    } else {
      throw Exception('Failed to load event');
    }
  } catch (error) {
    print('Error: $error'); // Debug error
    throw error;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> searchEvents(String query) async {
    _isLoading = true;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final response = await http.get(
        Uri.parse('http://192.168.243.187:3001/user/events/search?query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        _events = data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        // Handle the case where the server doesn't return a 200 response
        _events = []; // Clear events in case of an error
      }
    } catch (error) {
      // Handle the error, e.g., show a dialog or set an error message
      _events = []; // Clear events in case of an error
    }

    _isLoading = false;
    notifyListeners(); // Notify listeners that loading has finished
  }


  Future<void> fetchMyEvents() async {
    _isLoading = true;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('currentUser');
      final user = json.decode(userString ?? '{}');
      final userId = user['_id'];

      final res = await http.get(
        Uri.parse('http://192.168.243.187:3001/user/your-events/$userId'),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        _events = data['events'];
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
