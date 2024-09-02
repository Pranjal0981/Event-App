import 'dart:convert';
import 'dart:io'; // For File class
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:http/http.dart' as http; // Import http package
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts package
import '../Providers/userProvider.dart'; // Import your UserProvider

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile; // Variable to hold the image file
  bool _isLoading = false; // Loading state flag

  late String _firstName;
  late String _lastName;
  late String _email;
  late String _phoneNumber;
  late String _address;

  final ImagePicker _picker = ImagePicker(); // Create an ImagePicker instance

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    // Initialize fields with current user data
    _firstName = user?['firstName'] ?? '';
    _lastName = user?['lastName'] ?? '';
    _email = user?['email'] ?? '';
    _phoneNumber = user?['phoneNumber'] ?? '';
    _address = user?['address'] ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // For gallery
    // Uncomment the following line if you want to use the camera instead
    // final pickedFile = await _picker.pickImage(source: ImageSource.camera); // For camera

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set the picked image file
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera); // For camera

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set the picked image file
      });
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.redAccent),
                title: Text('Choose from Gallery', style: GoogleFonts.dancingScript(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.redAccent),
                title: Text('Take a Photo', style: GoogleFonts.dancingScript(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.redAccent),
                title: Text('Cancel', style: GoogleFonts.dancingScript(fontSize: 16)),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.dancingScript(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.redAccent),
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                
                setState(() {
                  _isLoading = true; // Start loading
                });

                userProvider.updateProfile(
                  firstName: _firstName,
                  lastName: _lastName,
                  email: _email,
                  phoneNumber: _phoneNumber,
                  address: _address,
                  imageFile: _imageFile, // Pass the image file
                ).then((_) {
                  setState(() {
                    _isLoading = false; // Stop loading
                  });
                  Navigator.of(context).pop(); // Go back after saving
                }).catchError((error) {
                  setState(() {
                    _isLoading = false; // Stop loading
                  });
                  // Handle errors if any
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile')),
                  );
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.redAccent),
                  SizedBox(height: 20),
                  Text('Updating...', style: GoogleFonts.dancingScript(fontSize: 18, color: Colors.redAccent)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile picture
                    Center(
                      child: GestureDetector(
                        onTap: () => _showImagePickerOptions(context),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                          child: _imageFile == null
                              ? Icon(Icons.camera_alt, color: Colors.white, size: 30)
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // First Name Field
                    _buildTextField(
                      initialValue: _firstName,
                      label: 'First Name',
                      onSaved: (value) => _firstName = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    // Last Name Field
                    _buildTextField(
                      initialValue: _lastName,
                      label: 'Last Name',
                      onSaved: (value) => _lastName = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    // Email Field
                    _buildTextField(
                      initialValue: _email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => _email = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    // Phone Number Field
                    _buildTextField(
                      initialValue: _phoneNumber,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => _phoneNumber = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    // Address Field
                    _buildTextField(
                      initialValue: _address,
                      label: 'Address',
                      maxLines: 3,
                      onSaved: (value) => _address = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String label,
    int? maxLines,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return AnimatedPadding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      duration: Duration(milliseconds: 300),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dancingScript(fontSize: 16, color: Colors.redAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          filled: true,
          fillColor: Colors.grey[900],
        ),
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
