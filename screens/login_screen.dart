import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: authProvider.isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or App Title
                    Text(
                      'Lets Go to Word Wars! !',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Display error message if it exists
                    if (authProvider.errorMessage != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    // Google Login Button
                    SocialLoginButton(
                      text: 'Sign in with Google',
                      imagePath: 'assets/google_logo.png',
                      onPressed: () async {
                        await authProvider.signInWithGoogle();
                      },
                    ),
                    SizedBox(height: 16),
                    // Twitter Login Button
                    SocialLoginButton(
                      text: 'Sign in with Twitter',
                      imagePath: 'assets/twitter_logo.png',
                      onPressed: () async {
                        await authProvider.signInWithTwitter();
                      },
                    ),
                    SizedBox(height: 16),
                    // Guest Login Button
                    SocialLoginButton(
                      text: 'Continue as Guest',
                      icon: Icons.person_outline,
                      onPressed: () async {
                        await authProvider.signInAnonymously();
                      },
                    ),
                    SizedBox(height: 30),
                    // Additional Option
                    Text(
                      'or',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    
                  ],
                ),
              ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
