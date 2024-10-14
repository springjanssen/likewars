import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RewardManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reward players based on their submissions
  Future<void> rewardPlayers(String topWord) async {
    if (topWord.isEmpty) return;

    final querySnapshot = await _firestore
        .collection('players')
        .where('lastSubmittedWord', isEqualTo: topWord)
        .get();

    final totalPlayers = querySnapshot.docs.length;

    // Using a batch to reduce Firestore writes
    WriteBatch batch = _firestore.batch();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      final playerDoc = querySnapshot.docs[i];
      final playerId = playerDoc.id;
      final rank = i + 1;

      final double rawFame = 100 * sqrt(totalPlayers) * (1 / rank) * (1 + (totalPlayers / 1000));
      final int fame = rawFame.round();
      final int likes = fame * 10;

      // Prepare updates in a batch
      final playerRef = _firestore.collection('players').doc(playerId);
      batch.update(playerRef, {
        'fame': FieldValue.increment(fame),
        'likes': FieldValue.increment(likes),
      });
      print('Player $playerId rewarded with $fame fame and $likes likes.');
    }

    // Commit the batch
    await batch.commit();
  }
}
