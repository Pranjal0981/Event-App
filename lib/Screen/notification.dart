import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildNotificationCard('New Feature Update', 'We have released a new feature...'),
            _buildNotificationCard('Event Reminder', 'Don’t forget about the upcoming event...'),
            _buildNotificationCard('Profile Update', 'Your profile has been successfully updated...'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(String title, String message) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.notifications, color: Colors.red, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
    );
  }
}
