import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart'; // Ensure to import your UserModel

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  User? _user;
  bool _isSignUp = false; // Indicates whether to show sign-up or sign-in
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      setState(() {
        _user = _auth.currentUser;
        _errorMessage = null;
        _isLoading = false;
      });
      _handleSuccessfulLogin();
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (!EmailValidator.validate(_emailController.text)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters long');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _user = _auth.currentUser;
        _errorMessage = null;
        _isLoading = false;
      });
      _handleSuccessfulLogin();
    } catch (e) {
      setState(() {
        _errorMessage = 'Email Sign-In failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithEmailPassword() async {
    if (!EmailValidator.validate(_emailController.text)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters long');
      return;
    }

    try {
      setState(() => _isLoading = true);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String displayName = userCredential.user!.displayName ?? 
                     _emailController.text.split('@')[0];

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'displayName': displayName,
        'photoURL': userCredential.user!.photoURL ?? '',
        'likes': 1000, // Gift 1000 likes on first login
        'fame': 0,
        'coins': 0,
        'lastLogin': Timestamp.now(),
        'score': 0,
        'lastSubmittedWord': null,
        'lastSubmissionDate': null,
      });

      setState(() {
        _user = _auth.currentUser;
        _errorMessage = null;
        _isLoading = false;
      });
      _handleSuccessfulLogin();
    } catch (e) {
      setState(() {
        _errorMessage = 'Email Sign-Up failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      setState(() => _isLoading = true);
      await _auth.signInAnonymously();
      setState(() {
        _user = _auth.currentUser;
        _errorMessage = null;
        _isLoading = false;
      });
      _handleSuccessfulLogin();
    } catch (e) {
      setState(() {
        _errorMessage = 'Anonymous Sign-In failed: $e';
        _isLoading = false;
      });
    }
  }

  void _handleSuccessfulLogin() async {
    if (_user == null) return;

    // Navigate to the home screen first
    Navigator.pushNamed(context, '/home');

    // Check the last login date and update likes
    final docRef = FirebaseFirestore.instance.collection('users').doc(_user!.uid);
    final docSnapshot = await docRef.get();

    // Access UserModel from the Provider
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (docSnapshot.exists) {
      final lastLogin = docSnapshot.data()?['lastLogin'] as Timestamp?;
      final now = DateTime.now();
      final lastLoginDate = lastLogin?.toDate();

      // If it's a new day, give 20 likes
      if (lastLoginDate == null || !isSameDay(lastLoginDate, now)) {
        await docRef.update({
          'likes': FieldValue.increment(20), // Give 20 likes
          'lastLogin': Timestamp.now(),
        });
      }
      
      // Update UserModel after logging in
      userModel.updateFromFirestore(docSnapshot); // Update UserModel with Firestore data
    } else {
      // If user document does not exist, create it
      await docRef.set({
        'email': _user!.email,
        'displayName': _user!.displayName ?? 'User',
        'photoURL': _user!.photoURL ?? '',
        'likes': 1000, // Gift 1000 likes on first login
        'fame': 0,
        'coins': 0,
        'lastLogin': Timestamp.now(),
        'score': 0,
        'lastSubmittedWord': null,
        'lastSubmissionDate': null,
      });
      
      // Now fetch the newly created document
      final newDocSnapshot = await docRef.get();
      userModel.updateFromFirestore(newDocSnapshot); // Update UserModel with Firestore data
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _user == null ? _buildLoginUI() : _buildLoggedInUI(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : (_isSignUp ? _signUpWithEmailPassword : _signInWithEmailPassword),
          child: _isLoading ? const CircularProgressIndicator() : Text(_isSignUp ? 'Sign Up' : 'Login'),
        ),
        TextButton(
          onPressed: _isLoading ? null : () {
            // Navigate to the SignUpPage instead of toggling _isSignUp
            Navigator.pushNamed(context, '/signup');
          },
          child: Text('Don\'t have an account? Sign Up'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _signInWithGoogle,
          child: const Text('Sign In with Google'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _signInAnonymously,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Login as Guest'),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildLoggedInUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'You are logged in!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await _auth.signOut();
            setState(() {
              _user = null;
              _errorMessage = null;
            });
          },
          child: const Text('Log Out'),
        ),
      ],
    );
  }
}