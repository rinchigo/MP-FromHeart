import 'package:flutter/material.dart';
import 'intro_screen.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'addmenu.dart';
import 'menu.dart';
import 'home_page.dart';
import 'profile_screen.dart';
import 'account_screen.dart';
import 'offers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/intro', // Starting screen
      routes: {
        '/intro': (context) => const IntroScreen(), // Intro Screen
        '/signup': (context) => const SignUpScreen(), // Sign-Up Screen
        '/login': (context) => const LoginScreen(), // Login Screen
        
        // Pass parameters dynamically to Home Page
        '/home': (context) => HomePage(username: "User", email: "user@gmail.com"),
        
        '/addmenu': (context) => AddMenuPage(), // Add Menu Page
        
        // Menu Page
        '/menu': (context) => MenuPage(),
        
        // Offers Page
        '/offers': (context) => const OffersPage(), // Offers Page
        
        // Account Screen
        '/account': (context) => const AccountScreen(email: "user@gmail.com"),
        
        // Profile Screen
        '/profile': (context) => ProfileScreen(
              fullName: "User",
              email: "user@gmail.com",
              password: "123456",
            ),
      },
    );
  }
}
