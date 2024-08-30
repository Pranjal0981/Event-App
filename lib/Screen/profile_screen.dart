import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userProvider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Fetch the current user when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider.fetchCurrentUser();
    });

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        // Show loading indicator if data is being fetched
        if (userProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
              backgroundColor: Colors.black,
            ),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          );
        }

        // Show message if user is not logged in
        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
              backgroundColor: Colors.black,
            ),
            body: Center(
              child: Text(
                'Please log in to view your profile.',
                style: TextStyle(fontSize: 18, color: Colors.red[600]),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.red),
                onPressed: () {
                  // Navigate to edit profile screen
                  Navigator.of(context).pushNamed('/editProfile');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User profile picture
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.red[800],
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(
                          user['avatarUrl'] ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // User name
                  Center(
                    child: Text(
                      user['name'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      user['email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Information section
                  Card(
                    elevation: 4,
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.red),
                            title: Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[800],
                              ),
                            ),
                            subtitle: Text(
                              user['phoneNumber'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey[700]),
                          ListTile(
                            leading: Icon(Icons.location_on, color: Colors.red),
                            title: Text(
                              'Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[800],
                              ),
                            ),
                            subtitle: Text(
                              user['address'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Logout button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.red[800],
                    ),
                    onPressed: () {
                      userProvider.logout(context);
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
