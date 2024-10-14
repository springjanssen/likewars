import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String? imagePath;  // Optional image path for Google/Twitter logos
  final IconData? icon;     // Optional icon for Guest login
  final VoidCallback onPressed;

  const SocialLoginButton({
    required this.text,
    this.imagePath,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: imagePath != null
          ? Image.asset(imagePath!, height: 24)  // Display image if provided
          : Icon(icon, size: 24),               // Or display icon if no image
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(200, 50),
      ),
      onPressed: onPressed,
    );
  }
}
