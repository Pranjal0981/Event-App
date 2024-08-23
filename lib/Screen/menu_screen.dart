import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.help, color: Colors.red),
            title: Text('Help Center'),
            onTap: () {
              Navigator.of(context).pushNamed('/helpCenter');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.red),
            title: Text('Your Profile'),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.event, color: Colors.red),
            title: Text('Your Events'),
            onTap: () {
              Navigator.of(context).pushNamed('/yourEvents');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.red),
            title: Text('Notifications'),
            onTap: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment, color: Colors.red),
            title: Text('Payments'),
            onTap: () {
              Navigator.of(context).pushNamed('/payments');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.red),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: Colors.red),
            title: Text('About Us'),
            onTap: () {
              Navigator.of(context).pushNamed('/aboutUs');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
