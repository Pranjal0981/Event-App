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
  String? _selectedEventType;
  TextEditingController _searchController = TextEditingController();

  final List<String> _eventTypes = [
    'Tech', 'History', 'Construction', 'Music', 'Art', 'Education', 'Science',
    'Food & Drink', 'Sports', 'Health', 'Travel', 'Business', 'Lifestyle', 'Entertainment',
    'Workshops', 'Conferences', 'Meetups'
  ];

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
    final eventType = _selectedEventType;

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
          eventType: eventType,
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
          title: Text(title, style: TextStyle(color: Colors.red[800])),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.red[800])),
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

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search City',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            Expanded(
              child: _filteredCities.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredCities.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(_filteredCities[index]),
                          onTap: () {
                            setState(() {
                              _selectedCity = _filteredCities[index];
                              _locationController.text = _selectedCity!;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text('No cities found.'),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      _dateController.text = pickedDate.toString().split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Event'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.red,
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
                    _buildTitleText('Event Title'),
                    _buildTextField(_titleController, 'Enter event title', Icons.title),
                    SizedBox(height: 16),
                    _buildTitleText('Description'),
                    _buildTextField(_descriptionController, 'Enter event description', Icons.description, maxLines: 4),
                    SizedBox(height: 16),
                    _buildTitleText('Location'),
                    GestureDetector(
                      onTap: () => _showCityPicker(context),
                      child: AbsorbPointer(
                        child: _buildTextField(_locationController, 'Tap to select location', Icons.location_city),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTitleText('Date'),
                    GestureDetector(
                      onTap: () => _pickDate(),
                      child: AbsorbPointer(
                        child: _buildTextField(_dateController, 'Select event date', Icons.calendar_today),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTitleText('Ticket Price'),
                    _buildTextField(_priceController, 'Enter ticket price', Icons.monetization_on),
                    SizedBox(height: 16),
                    _buildTitleText('Event Type'),
                    DropdownButtonFormField<String>(
                      value: _selectedEventType,
                      items: _eventTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.1),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEventType = newValue;
                        });
                      },
                      hint: Text('Select event type'),
                    ),
                    SizedBox(height: 16),
                    _buildTitleText('Event Image'),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.1),
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : Center(child: Text('Tap to select image')),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _uploadEvent,
                        child: Text('Upload Event'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          overlayColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTitleText(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {int? maxLines}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black.withOpacity(0.1),
      ),
      maxLines: maxLines ?? 1,
    );
  }
}
