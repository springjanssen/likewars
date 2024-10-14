import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart' as auth; // Create an alias for the AuthProvider
import 'package:intl/intl.dart'; // Import for date formatting

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth.AuthProvider>(context);
    final user = authProvider.user;
    final playerModel = authProvider.playerModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user?.photoURL != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            SizedBox(height: 16),
            Text(
              'Display Name: ${user?.displayName ?? 'Guest'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),

            // Display additional player model information
            if (playerModel != null) ...[
              Text('First Name: ${playerModel.firstName}', style: TextStyle(fontSize: 18)),
              Text('Last Name: ${playerModel.lastName}', style: TextStyle(fontSize: 18)),
              Text('Likes: ${playerModel.likes}', style: TextStyle(fontSize: 18)),
              Text('Fame: ${playerModel.fame}', style: TextStyle(fontSize: 18)),
              Text('Coins: ${playerModel.coins}', style: TextStyle(fontSize: 18)),
              Text('Score: ${playerModel.score}', style: TextStyle(fontSize: 18)),
              Text('Last Submitted Word: ${playerModel.lastSubmittedWord ?? 'N/A'}', style: TextStyle(fontSize: 18)),
              Text('Last Submission Date: ${playerModel.lastSubmissionDate != null ? DateFormat.yMMMd().format(playerModel.lastSubmissionDate!.toDate()) : 'N/A'}', style: TextStyle(fontSize: 18)),
              Text('Last Login: ${DateFormat.yMMMd().format(playerModel.lastLogin.toDate())}', style: TextStyle(fontSize: 18)),
              // Add other fields from PlayerModel as needed
            ],
          ],
        ),
      ),
    );
  }
}
