import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart'; // Import your PlayerModel
import '../models/special_challenge.dart'; // Import your SpecialChallengeModel

class SpecialChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to enter a special challenge
  Future<bool> enterChallenge(PlayerModel player, SpecialChallengeModel challenge) async {
    if (player.likes >= challenge.likesCost) {
      // Deduct likes using the updateRewards method
      player.updateRewards(addedLikes: -challenge.likesCost); // Deduct likes
      player.notifyListeners(); // Notify listeners for UI updates

      // Save the player's entry into Firestore
      await _firestore.collection('specialChallenges').doc(challenge.id).collection('participants').add({
        'playerId': player.id,
        'entryDate': Timestamp.now(),
      });

      return true; // Successfully entered the challenge
    } else {
      return false; // Not enough likes to enter
    }
  }

  // Method to distribute rewards after the challenge ends
  Future<void> distributeRewards(SpecialChallengeModel challenge) async {
    final participantsSnapshot = await _firestore.collection('specialChallenges')
        .doc(challenge.id)
        .collection('participants')
        .get();

    List<PlayerModel> participants = [];

    for (var doc in participantsSnapshot.docs) {
      // Assume we have a method to get PlayerModel from playerId
      PlayerModel player = await getPlayerModel(doc['playerId']);
      participants.add(player);
    }

    final totalLikes = participants.length * challenge.likesCost;

    for (int rank = 0; rank < participants.length; rank++) {
      PlayerModel player = participants[rank];
      int reward;

      if (rank == 0) {
        reward = totalLikes; // Top player gets all
      } else {
        reward = (totalLikes / (rank + 1)).floor(); // Split based on rank
      }

      player.updateRewards(addedLikes: reward); // Give likes as reward
    }
  }

  // Helper method to get PlayerModel from Firestore
  Future<PlayerModel> getPlayerModel(String playerId) async {
    final playerDoc = await _firestore.collection('players').doc(playerId).get();
    return PlayerModel.fromFirestore(playerDoc);
  }
}
