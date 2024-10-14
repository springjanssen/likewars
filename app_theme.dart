import 'package:flutter/material.dart';

class LikeWarsTheme {
  static ThemeData get theme {
    return ThemeData(
      // Primary colors
      primaryColor: Colors.yellow,
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(secondary: Colors.red, surface: const Color(0xFFF7F2E7)),
      scaffoldBackgroundColor: const Color(0xFFF7F2E7), // Cream background

      // AppBar theme
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 2,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'PatrickHand', // Handwritten font
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: 'PatrickHand',
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'PatrickHand',
        ),
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'PatrickHand',
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow, // Button background color
          foregroundColor: Colors.black, // Button text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        elevation: 5,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontFamily: 'PatrickHand',
        ),
        labelStyle: const TextStyle(
          color: Colors.black,
          fontFamily: 'PatrickHand',
        ),
        contentPadding: const EdgeInsets.all(12),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Divider theme
      dividerColor: Colors.black26,
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Colors.black26,
      ),

      // SnackBar theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.red,
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: Colors.yellow,
      ),

      // TabBar theme
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black38,
        indicatorColor: Colors.yellow,
      ),

      // Tooltip theme
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
