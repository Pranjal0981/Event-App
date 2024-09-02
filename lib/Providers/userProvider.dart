import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class UserProvider extends ChangeNotifier {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  String? _orderId;
  String? _token;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  List<Map<String, dynamic>> _events = [];
  List<String> _favoriteEventIds = [];
  List<String> get favoriteEventIds => _favoriteEventIds;
  Map<String, dynamic>? _currentEvent;
 List<dynamic> _myEvents = [];
  List<dynamic> get myEvents => _myEvents;
  Map<String, bool> _filters = {};
  Map<String, bool> get filters => _filters;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  List<Map<String, dynamic>> get events => _events;
  Map<String, dynamic>? get currentEvent => _currentEvent;
 List<dynamic> _bookings = [];

  List<dynamic> get bookings => _bookings;
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  

  Future<void> signup(String name, String email, String phoneNumber, String password) async {
    try {
      setLoading(true);
      print(name);
      print(email);
      print(phoneNumber);
      print(password);
      final response = await http.post(
        Uri.parse('http://192.168.243.187:3001/user/registerUser'),
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


Future<void> updateProfile({
  required String firstName,
  required String lastName,
  required String email,
  required String phoneNumber,
  required String address,
  File? imageFile, // Optional image file parameter
}) async {
  _isLoading = true;
  notifyListeners();

  final token = _token ?? await _getTokenFromPrefs();
  if (token == null) {
    throw Exception('No token found');
  }

  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('currentUser');
  final user = json.decode(userString ?? '{}');
  final userId = user['_id'];

  final uri = Uri.parse('http://192.168.243.187:3001/user/updateProfile/$userId');
  final request = http.MultipartRequest('PUT', uri);

  // Add headers
  request.headers['Authorization'] = 'Bearer $token';

  // Add text fields
  request.fields['firstName'] = firstName;
  request.fields['lastName'] = lastName;
  request.fields['email'] = email;
  request.fields['phoneNumber'] = phoneNumber;
  request.fields['address'] = address;

  // Add image file if available
  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      _currentUser = json.decode(responseBody);
    } else {
      final errorResponse = json.decode(responseBody);
      print('Failed to update profile: ${errorResponse['message'] ?? response.reasonPhrase}');
      throw Exception('Failed to update profile');
    }
  } catch (error) {
    print('Error: $error');
  } finally {
    _isLoading = false;
    notifyListeners();
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
if (response.statusCode == 201) {  // Update to match your success status code
  final responseData = await response.stream.bytesToString();
  final result = json.decode(responseData);
  if (result['message'] == 'Event uploaded successfully') {
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

 Future<void> logout(BuildContext context) async {
    try {
          final token = _token ?? await _getTokenFromPrefs();
      final response = await http.post(
        Uri.parse('http://192.168.243.187:3001/user/logout'), // Replace with your logout API URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Clear user data
        _currentUser = null;

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');

        // Notify listeners to update UI
        notifyListeners();

        // Navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        _showErrorDialog(context, 'Logout failed. Please try again.');
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred. Please try again.');
    }
  }
  
 
  Future<void> deleteEvent(String id) async {
    final url = Uri.parse('http://192.168.243.187:3001/user/deleteEvents/$id');

    // Retrieve the token from your preferred method
    final token = _token ?? await _getTokenFromPrefs();

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Add bearer token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Successfully deleted, update local state
        _events.removeWhere((event) => event['_id'] == id);
        notifyListeners();
      } else {
        // Handle unsuccessful response
        final errorMessage = 'Failed to delete event: ${response.reasonPhrase}';
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Log the error or show a user-friendly message
      print('Error deleting event: $error');
      rethrow; // Rethrow the error to be handled by the caller if needed
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

Future<void> applyFilters(
  Map<String, bool> cityFilters,
  Map<String, bool> priceFilters,
  Map<String, bool> typeFilters
) async {
  _isLoading = true;
  notifyListeners(); // Notify listeners that loading has started

  try {
    // Construct query parameters for each filter category
    final cityQuery = cityFilters.entries
        .where((entry) => entry.value) // Only include selected filters
        .map((entry) => 'city[]=${Uri.encodeComponent(entry.key)}')
        .join('&');

    final priceQuery = priceFilters.entries
        .where((entry) => entry.value)
        .map((entry) => 'price[]=${Uri.encodeComponent(entry.key)}')
        .join('&');

    final typeQuery = typeFilters.entries
        .where((entry) => entry.value)
        .map((entry) => 'type[]=${Uri.encodeComponent(entry.key)}')
        .join('&');

    // Combine all query strings into a single query string
    final queryString = [cityQuery, priceQuery, typeQuery]
        .where((query) => query.isNotEmpty) // Remove empty query strings
        .join('&');

    // Construct the full URL for the request
    final url = 'http://192.168.243.187:3001/user/applyFilters?$queryString';

    // Perform the HTTP GET request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        // Decode JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        
        // Extract the list of events from the response
        final List<dynamic> events = jsonResponse['events'] as List<dynamic>? ?? [];

        // Convert the events list to a list of maps
        _events = events.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        // Handle JSON decoding error
        _events = [];
        print('Error decoding JSON response: $e');
        // Optionally, notify the user about the issue
      }
    } else {
      // Handle the case where the server returns an error status
      _events = [];
      print('Server error: ${response.statusCode}');
      // Optionally, notify the user about the issue
    }
  } catch (error) {
    // Handle network or other unexpected errors
    _events = [];
    print('Error applying filters: $error');
    // Optionally, notify the user about the issue
  }

  _isLoading = false;
  notifyListeners(); // Notify listeners that loading has finished
}


  Future<void> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('currentUser');
    final user = json.decode(userString ?? '{}');
    final userId = user['_id'];
    final String apiUrl = 'http://192.168.243.187:3001/user/fetchBookings';

    try {
      final token = prefs.getString('token'); // Assuming you have stored the token in SharedPreferences
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$apiUrl?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _bookings = json.decode(response.body)['bookings'];
        print(bookings);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch bookings: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      throw Exception('Error fetching bookings');
    }
  }

}


