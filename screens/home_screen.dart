import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../models/challenge_model.dart'; // Import the ChallengeModel

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final challengeModel = Provider.of<ChallengeModel>(context); // Get ChallengeModel

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
              radius: 16,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile'); // Navigate to profile screen
            },
          ),
        ],
      ),
      body: Center( // Center the content of the page
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0), // Add some horizontal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretched buttons
            children: [
              if (user?.displayName != null)
                Text(
                  'Welcome, ${user!.displayName}!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 16),

              // Daily Challenge Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/dailyChallenge'); // Use named route
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Join Daily Challenge',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 24),

              // Leaderboard/Ranking Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ranking'); // Use named route
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                child: Text(
                  'View Rankings',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 24),

              // // Special Challenge Button
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pushNamed(context, '/specialChallenge'); // Navigate to Special Challenge Screen
              //   },
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 20),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //     backgroundColor: Colors.purpleAccent,
              //   ),
              //   child: Text(
              //     'Join Special Challenge',
              //     style: TextStyle(fontSize: 18, color: Colors.white),
              //   ),
              // ),
              // SizedBox(height: 24),

              // // Test Challenge Reset Button
              // ElevatedButton(
              //   onPressed: () async {
              //     await challengeModel.concludeChallengePrematurely(); // Call the method
              //   },
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 20),
              //     backgroundColor: Colors.blueAccent, // Color for the test button
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //   ),
              //   child: Text(
              //     'Test Challenge Reset',
              //     style: TextStyle(fontSize: 18, color: Colors.white),
              //   ),
              // ),
              // SizedBox(height: 24),

              // Log Out Button
              ElevatedButton(
                onPressed: () async {
                  await authProvider.signOut();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
