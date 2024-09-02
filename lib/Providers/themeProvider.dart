import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData.brightness == Brightness.dark;

  void toggleTheme() {
    _themeData = isDarkMode
        ? _buildLightTheme()
        : _buildDarkTheme();
    notifyListeners();
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.redAccent,
      colorScheme: ColorScheme.light().copyWith(
        primary: Colors.redAccent,
        secondary: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.openSans(color: Colors.black),
        bodyMedium: GoogleFonts.openSans(color: Colors.black),
        displayLarge: GoogleFonts.openSans(color: Colors.black, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.openSans(color: Colors.black, fontWeight: FontWeight.bold),
        // Add other text styles as needed
      ),
      // Add other theme properties if needed
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.redAccent,
      colorScheme: ColorScheme.dark().copyWith(
        primary: Colors.redAccent,
        secondary: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.openSans(color: Colors.white),
        bodyMedium: GoogleFonts.openSans(color: Colors.white),
        displayLarge: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold),
        // Add other text styles as needed
      ),
      // Add other theme properties if needed
    );
  }
}
