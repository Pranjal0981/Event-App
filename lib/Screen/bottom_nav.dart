import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For additional icons
import 'package:grocery_app/Screen/home_screen.dart';
import 'package:grocery_app/Screen/upload_event.dart';
import 'package:grocery_app/Screen/favorites_screen.dart';
import 'package:grocery_app/Screen/profile_screen.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    UploadEventsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _selectedIndex == 0
                  ? Icon(Icons.home, key: ValueKey('home'))
                  : Icon(Icons.home_outlined, key: ValueKey('home_outlined')),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _selectedIndex == 1
                  ? Icon(Icons.upload_file, key: ValueKey('upload'))
                  : Icon(Icons.upload_file_outlined, key: ValueKey('upload_outlined')),
            ),
            label: 'Upload Event',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _selectedIndex == 2
                  ? Icon(Icons.favorite, key: ValueKey('favorites'))
                  : Icon(Icons.favorite_border, key: ValueKey('favorites_border')),
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _selectedIndex == 3
                  ? Icon(Icons.person, key: ValueKey('profile'))
                  : Icon(Icons.person_outline, key: ValueKey('profile_outline')),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey[400],
        elevation: 8.0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
