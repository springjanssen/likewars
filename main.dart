import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:likewars/firebase_options.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'models/player_model.dart'; // Import PlayerModel
import 'models/challenge_model.dart'; // Import ChallengeModel
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/special_challenge_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => PlayerModel(
            id: '', // Placeholder, you will update this after user logs in
            firstName: '',
            lastName: '',
            displayName: '',
            photoURL: '',
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChallengeModel(
            challengeId: '',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Like Wars!',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/home': (context) => HomeScreen(),
          '/dailyChallenge': (context) => DailyChallengeScreen(),
          '/ranking': (context) => RankingScreen(),
          '/profile': (context) => ProfileScreen(),
          '/specialChallenge': (context) => SpecialChallengeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final challenge = Provider.of<ChallengeModel>(context, listen: false);
    final playerModel = Provider.of<PlayerModel>(context, listen: false);

    // Check authentication status
    if (authProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (authProvider.user == null) {
      return LoginScreen(); // Show login screen if no user is signed in
    } else {
      // Update PlayerModel with user data after logging in
      playerModel.id = authProvider.user!.uid; 
      playerModel.displayName = authProvider.user!.displayName ?? 'Guest';
      playerModel.photoURL = authProvider.user!.photoURL ?? '';

      // Check for an active challenge and auto-schedule if needed
      challenge.checkAndScheduleChallenge();

      return HomeScreen(); // Show home screen if a user is signed in
    }
  }
}
