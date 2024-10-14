import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/player_model.dart'; // Import your PlayerModel
import '../models/special_challenge.dart'; // Import your SpecialChallengeModel
import '../services/special_challenge_service.dart'; // Import your service for handling challenge logic

class SpecialChallengeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerModel = Provider.of<PlayerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Special Challenges"),
      ),
      body: FutureBuilder<List<SpecialChallengeModel>>(
        future: fetchActiveChallenges(), // Function to fetch active challenges
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading challenges"));
          }

          final challenges = snapshot.data ?? [];

          return ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(challenge.word),
                  subtitle: Text("Cost: ${challenge.likesCost} Likes"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      enterChallenge(context, playerModel, challenge);
                    },
                    child: Text("Enter"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<SpecialChallengeModel>> fetchActiveChallenges() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('specialChallenges')
        .where('isActive', isEqualTo: true) // Assuming there's an isActive field
        .get();

    return snapshot.docs.map((doc) => SpecialChallengeModel.fromFirestore(doc)).toList();
  }

  void enterChallenge(BuildContext context, PlayerModel playerModel, SpecialChallengeModel challenge) {
    if (playerModel.likes >= challenge.likesCost) {
      playerModel.likes -= challenge.likesCost; // Deduct likes
      playerModel.notifyListeners(); // Notify UI

      // Here you could save the player entry into Firestore if needed

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully entered the challenge!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough likes to enter!")),
      );
    }
  }
}
