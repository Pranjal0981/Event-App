import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/themeProvider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildSettingOption(context, 'Account Settings', Icons.account_circle, '/accountSettings'),
            _buildSettingOption(context, 'Privacy Settings', Icons.privacy_tip, '/privacySettings'),
            _buildSettingOption(context, 'Notification Settings', Icons.notifications, '/notificationSettings'),
            _buildSettingOption(context, 'Language', Icons.language, '/languageSettings'),
            _buildSettingOption(context, 'Theme', Icons.brightness_6, '/themeSettings'),
            _buildThemeToggle(context, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(BuildContext context, String title, IconData icon, String route) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.red, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    return SwitchListTile(
      title: Text(
        'Dark Mode',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      value: themeProvider.isDarkMode,
      onChanged: (bool value) {
        themeProvider.toggleTheme();
      },
    );
  }
}
