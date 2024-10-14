import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Notify players about the challenge start
  Future<void> notifyChallengeStart(String challengeId, List<String> playerIds) async {
    for (var playerId in playerIds) {
      await _firestore.collection('players').doc(playerId).collection('notifications').add({
        'type': 'challenge_start',
        'challengeId': challengeId,
        'message': 'A new challenge has started! Submit your word!',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  // Notify players about the top word, rewards, and their rank
  Future<void> notifyTopWordAndRewards(String challengeId, String topWord, Map<String, int> rewards, Map<String, int> playerRanks, List<String> playerIds) async {
    for (var playerId in playerIds) {
      int reward = rewards[playerId] ?? 0; // Get reward for each player
      int rank = playerRanks[playerId] ?? -1; // Get rank for each player, -1 if not ranked

      String rankMessage = rank > 0 ? 'Your rank was $rank.' : 'You did not rank this time.';
      
      await _firestore.collection('players').doc(playerId).collection('notifications').add({
        'type': 'challenge_result',
        'challengeId': challengeId,
        'message': 'The challenge has ended! The top word was "$topWord". You earned $reward coins! $rankMessage',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String playerId, String notificationId) async {
    await _firestore.collection('players').doc(playerId).collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }
  
}
