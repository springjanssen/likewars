// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = themes[0]; // Default to Light Mode

  AppTheme get currentTheme => _currentTheme;

  bool get isDarkMode => _currentTheme == themes[1]; // Assuming themes[1] is Dark Mode

  ThemeData getTheme() => _currentTheme.themeData; // Method to get current theme data

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
