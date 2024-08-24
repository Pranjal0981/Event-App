import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData.brightness == Brightness.dark;

  void toggleTheme() {
    _themeData = isDarkMode
        ? ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.redAccent,
            colorScheme: ColorScheme.light().copyWith(
              primary: Colors.redAccent,
              secondary: Colors.red,
            ),
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
              bodySmall: TextStyle(color: Colors.black),
            ),
          )
        : ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.redAccent,
            colorScheme: ColorScheme.dark().copyWith(
              primary: Colors.redAccent,
              secondary: Colors.red,
            ),
            scaffoldBackgroundColor: Colors.black,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
            ),
          );
    notifyListeners();
  }
}
