import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/themeProvider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: SwitchListTile(
          title: const Text(
            'Dark Mode',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          value: isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
          activeColor: Colors.redAccent,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey[700],
        ),
      ),
    );
  }
}
