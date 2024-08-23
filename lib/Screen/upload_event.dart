import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class UploadEventsScreen extends StatefulWidget {
  @override
  _UploadEventsScreenState createState() => _UploadEventsScreenState();
}

class _UploadEventsScreenState extends State<UploadEventsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  List<String> _cities = [];
  List<String> _filteredCities = [];
  String? _selectedCity;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
    _searchController.addListener(_filterCities);
  }

  Future<void> _loadCities() async {
    final jsonString = await rootBundle.loadString('assets/cities.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      _cities = jsonResponse.cast<String>();
      _filteredCities = _cities;
    });
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = _cities
          .where((city) => city.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadEvent() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final location = _selectedCity ?? _locationController.text;
    final date = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (_imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await Provider.of<UserProvider>(context, listen: false).uploadEvent(
          title: title,
          description: description,
          location: location,
          date: date,
          price: price,
          image: _imageFile!,
        );

        if (success) {
          _showAlertDialog('Success', 'Event uploaded successfully.');
        } else {
          _showAlertDialog('Error', 'Failed to upload event. Please try again.');
        }
      } catch (e) {
        print('Error during event upload: $e');
        _showAlertDialog('Error', 'Failed to upload event. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showAlertDialog('Warning', 'No image selected.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter event title',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter event description',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Search city...',
                      ),
                    ),
                    SizedBox(height: 8),
                    _filteredCities.isNotEmpty
                        ? DropdownButtonFormField<String>(
                            value: _selectedCity,
                            items: _filteredCities
                                .map((city) => DropdownMenuItem(
                                      value: city,
                                      child: Text(city),
                                    ))
                                .toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCity = newValue;
                                _locationController.text = newValue ?? '';
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select event location',
                            ),
                          )
                        : Text('No cities found.'),
                    SizedBox(height: 16),
                    Text('Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter event date (yyyy-mm-dd)',
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          _dateController.text = pickedDate.toString().split(' ')[0];
                        }
                      },
                      readOnly: true,
                    ),
                    SizedBox(height: 16),
                    Text('Ticket Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter ticket price',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    Text('Event Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            height: 150,
                          )
                        : Text('No image selected.'),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Choose Image'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _uploadEvent,
                      child: Text('Upload Event'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
