import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/screens/home_screen.dart';
import 'app/screens/login_screen.dart';
import 'app/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Dio dio;

  MyApp({required this.isLoggedIn})
      : dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.0.99:8000/api/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cosmos Test',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: createMaterialColor(const Color(0xFFff1415)),
      ),
      home: isLoggedIn ? HomeScreen(dio: dio) : LoginScreen(dio: dio),
      routes: {
        '/signup': (context) => SignupScreen(dio: dio),
        '/home': (context) => HomeScreen(dio: dio),
        '/login': (context) => LoginScreen(dio: dio),
      },
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    };
    return MaterialColor(color.value, swatch);
  }
}