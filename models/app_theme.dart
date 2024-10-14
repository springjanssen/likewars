// lib/models/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final ThemeData themeData;

  AppTheme({required this.name, required this.themeData});
}

// List of themes
List<AppTheme> themes = [
  AppTheme(
    name: 'Light Mode',
    themeData: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Replaced bodyText1
        bodyMedium: TextStyle(color: Colors.black54), // Replaced bodyText2
      ),
      appBarTheme: AppBarTheme(
        color: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Updated titleTextStyle
      ),
    ),
  ),
  AppTheme(
    name: 'Dark Mode',
    themeData: ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey,
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white), // Replaced bodyText1
        bodyMedium: TextStyle(color: Colors.white70), // Replaced bodyText2
      ),
      appBarTheme: AppBarTheme(
        color: Colors.blueGrey,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Updated titleTextStyle
      ),
    ),
  ),
];
