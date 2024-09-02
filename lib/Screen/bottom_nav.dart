// lib/widgets/bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:grocery_app/Screen/home_Screen.dart';
import 'package:grocery_app/Screen/upload_event.dart';
import 'package:grocery_app/Screen/favorites_screen.dart';
import 'package:grocery_app/Screen/profile_screen.dart';
import 'package:grocery_app/Screen/menu_screen.dart'; // Import the MenuScreen
import 'package:grocery_app/Screen/booking_screen.dart'; // Import the BookingScreen

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    UploadEventsScreen(),
    FavoriteEventsScreen(),
    ProfileScreen(),
    BookingScreen(), // Add BookingScreen to the list
  ];

  void _onItemTapped(int index) {
    if (index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      _navigateToMenuScreen(context);
    }
  }

  void _navigateToMenuScreen(BuildContext context) {
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MenuScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide in from the right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
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
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _selectedIndex == 4
                  ? Icon(Icons.bookmark, key: ValueKey('bookings'))
                  : Icon(Icons.bookmark_border, key: ValueKey('bookings_border')),
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _navigateToMenuScreen(context);
              },
            ),
            label: 'Menu',
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
