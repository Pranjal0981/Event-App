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
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show message if user is not logged in
        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: Center(
              child: Text('Please log in to view your profile.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit profile screen
                  Navigator.of(context).pushNamed('/editProfile');
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile picture
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user['avatarUrl'] ?? 'https://via.placeholder.com/150'),
                ),
                SizedBox(height: 16),
                // User name
                Text(
                  'Name: ${user['name'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // User email
                Text(
                  'Email: ${user['email'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                // User phone number
                Text(
                  'Phone Number: ${user['phoneNumber'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                // User address
                Text(
                  'Address: ${user['address'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 24),
                // Logout button
                ElevatedButton(
                  onPressed: () {
                    // userProvider.logout(); // Implement logout in UserProvider
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
