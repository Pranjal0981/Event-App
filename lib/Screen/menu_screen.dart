import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        color: Colors.black,
        child: ListView(
          children: [
            _buildMenuItem(
              context,
              icon: Icons.help,
              title: 'Help Center',
              onTap: () {
                Navigator.of(context).pushNamed('/helpCenter');
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.person,
              title: 'Your Profile',
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.event,
              title: 'Your Events',
              onTap: () {
                Navigator.of(context).pushNamed('/yourEvents');
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                Navigator.of(context).pushNamed('/notifications');
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.payment,
              title: 'Payments',
              onTap: () {
                Navigator.of(context).pushNamed('/payments');
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.info,
              title: 'About Us',
              onTap: () {
                Navigator.of(context).pushNamed('/aboutUs');
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.red, size: 28),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.red.withOpacity(0.6),
      thickness: 0.8,
      indent: 20,
      endIndent: 20,
    );
  }
}
