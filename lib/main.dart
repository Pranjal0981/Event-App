import 'package:flutter/material.dart';
import 'package:grocery_app/Screen/Splash_Screen.dart';
import 'package:grocery_app/Screen/edit_profile.dart';
import 'package:grocery_app/Screen/my_events.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/themeProvider.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:grocery_app/Screen/notification.dart';
import 'package:grocery_app/Screen/setting_screen.dart';
import 'package:grocery_app/Screen/theme_setting.dart';
import 'package:grocery_app/Auth/login_screen.dart';
import 'package:grocery_app/Auth/register_screen.dart';
import 'package:grocery_app/Auth/forget_screen.dart';
import 'package:grocery_app/Screen/bottom_nav.dart';
import 'package:grocery_app/Screen/about_us_screen.dart';
import 'package:grocery_app/Screen/help_screen.dart';
import 'package:grocery_app/Screen/payment_screen.dart';
import 'package:grocery_app/Screen/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            ThemeData(
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
            ),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.themeData,
      home: SplashScreen(), // Set SplashScreen as the initial screen
      routes: {
        '/register': (context) => RegisterScreen(),
        '/forget-password': (context) => RequestOtpScreen(),
        '/home': (context) => BottomNav(),
        '/login': (context) => LoginScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/payments': (context) => PaymentsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/aboutUs': (context) => AboutUsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/helpCenter': (context) => HelpCenterScreen(),
        '/themeSettings': (context) => ThemeSettingsScreen(),
        '/yourEvents':(context)=>MyEventsScreen(),
        '/editProfile':(context)=>EditProfileScreen()
      },
    );
  }
}
