// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:likewars/screens/login_screen.dart';
import 'dart:async'; // For Future

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onGetStarted() {
    // Navigate to login or main screen here
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onLogin() {
    // Navigate to login screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<bool> _checkImageExists(String imagePath) async {
    try {
      await rootBundle.load(imagePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildPage(
            color: Colors.blueAccent,
            image: 'assets/images/welcome1.png',
            slogan: 'Join the Battle of Words!',
          ),
          _buildPage(
            color: Colors.purpleAccent,
            image: 'assets/images/welcome2.png',
            slogan: 'Compete for Fame and Glory!',
          ),
          _buildPage(
            color: Colors.orangeAccent,
            image: 'assets/images/welcome3.png',
            slogan: 'Can You Become the Like King?',
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentIndex == 2)
              ElevatedButton(
                onPressed: _onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Get Started',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // You can change the color
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            // Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required Color color, required String image, required String slogan}) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: FutureBuilder<bool>(
                future: _checkImageExists(image),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading while checking
                  }
                  if (snapshot.hasData && snapshot.data == true) {
                    return Image.asset(
                      image,
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Container(
                      height: 250,
                      width: 250,
                      color: Colors.grey, // Fallback color
                      child: Center(
                        child: Text(
                          'Image Not Found',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Text(
            slogan,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
