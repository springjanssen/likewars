// lib/screens/theme_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';

class ThemeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Theme'),
      ),
      body: ListView.builder(
        itemCount: themes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              themes[index].name,
              style: TextStyle(
                color: themeProvider.currentTheme.themeData.textTheme.bodyLarge!.color,
              ),
            ),
            tileColor: themeProvider.currentTheme.themeData.scaffoldBackgroundColor, // Use scaffoldBackgroundColor
            onTap: () {
              themeProvider.setTheme(themes[index]);
            },
          );
        },
      ),
    );
  }
}
