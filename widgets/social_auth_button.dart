import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String provider;
  final VoidCallback onPressed;

  const SocialAuthButton({
    Key? key,
    required this.provider,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: provider == 'Google' ? Colors.white : Colors.blue, 
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add provider icon here (e.g., Google or Twitter logo)
          Image.asset(
            provider == 'Google'
                ? 'assets/google_logo.png' // Replace with your asset path
                : 'assets/twitter_logo.png', // Replace with your asset path
            height: 24,
          ),
          SizedBox(width: 10),
          Text(
            'Continue with $provider',
            style: TextStyle(
              color: provider == 'Google' ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}