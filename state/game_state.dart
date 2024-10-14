import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

class GameState extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _nextResetTime = DateTime.now();
  bool _hasSubmittedToday = false;
  String _currentDateKey = '';

  DateTime get nextResetTime => _nextResetTime;
  bool get hasSubmittedToday => _hasSubmittedToday;

  GameState() {
    _initializeNextResetTime();
    _startDailyResetTimer();
    _listenToDailyWords();
    updateUserLastLogin();
    _setCurrentDateKey();
  }

  void _setCurrentDateKey() {
    _currentDateKey = DateFormat('ddMMyyyy').format(DateTime.now());
  }

  void _initializeNextResetTime() {
    final now = DateTime.now().toUtc();
    _nextResetTime = DateTime.utc(now.year, now.month, now.day, 15, 0, 0);
    if (now.isAfter(_nextResetTime)) {
      _nextResetTime = _nextResetTime.add(Duration(days: 1));
    }
  }

  void _startDailyResetTimer() {
    Timer.periodic(Duration(minutes: 1), (timer) {
      if (DateTime.now().toUtc().isAfter(_nextResetTime)) {
        _resetDaily();
      }
    });
  }

  void _resetDaily() async {
    print("Resetting daily challenge");

    // Notify all users of new submission time
    notifyUsersOfNewSubmissionTime();

    // Calculate and update daily scores
    await calculateAndUpdateDailyScores();

    // Notify each player with their word rank, fame, and likes gained
    await _notifyPlayersWithDailyResults();

    // Reset for the next day
    _hasSubmittedToday = false;
    _initializeNextResetTime();
    _setCurrentDateKey();
    notifyListeners();
  }

  void notifyUsersOfNewSubmissionTime() {
    print("You can submit a new word now!");
  }

  void _listenToDailyWords() {
    _firestore.collection('daily_words').snapshots().listen((snapshot) {
      notifyListeners();
    });
  }

  Future<void> updateUserLastLogin() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginDate': FieldValue.serverTimestamp(),
      });
      print('Updated lastLoginDate in Firestore');
    }
  }

  Future<void> calculateAndUpdateDailyScores() async {
    final snapshot = await _firestore
        .collection('daily_challenges')
        .doc(_currentDateKey)
        .collection('words')
        .orderBy('count', descending: true)
        .get();

    int totalPlayers = await _getTotalPlayers();

    for (int i = 0; i < snapshot.docs.length; i++) {
      var doc = snapshot.docs[i];
      int rank = i + 1;
      int fame = _calculateFame(totalPlayers, rank);
      int likes = fame * 10;

      await _firestore.collection('users')
          .where('lastSubmittedWord', isEqualTo: doc.id)
          .where('lastSubmissionDate', isGreaterThanOrEqualTo: DateTime.parse(_currentDateKey))
          .get()
          .then((userSnapshot) {
        for (var userDoc in userSnapshot.docs) {
          userDoc.reference.update({
            'fame': FieldValue.increment(fame),
            'likes': FieldValue.increment(likes),
          });
        }
      });
    }
  }

  Future<void> _notifyPlayersWithDailyResults() async {
    final totalPlayers = await _getTotalPlayers();

    // Get the daily submissions ordered by count (popularity)
    final snapshot = await _firestore
        .collection('daily_challenges')
        .doc(_currentDateKey)
        .collection('words')
        .orderBy('count', descending: true)
        .get();

    // Notify each player about their performance
    for (int i = 0; i < snapshot.docs.length; i++) {
      var wordDoc = snapshot.docs[i];
      int rank = i + 1;  // Word rank
      int fame = _calculateFame(totalPlayers, rank);  // Fame based on rank
      int likes = fame * 10;  // Likes derived from fame

      // Get all users who submitted this word today
      final userSnapshot = await _firestore.collection('users')
        .where('lastSubmittedWord', isEqualTo: wordDoc.id)
        .where('lastSubmissionDate', isGreaterThanOrEqualTo: DateTime.parse(_currentDateKey))
        .get();

      // Notify each user with their results
      for (var userDoc in userSnapshot.docs) {
        final userId = userDoc.id;

        // Send notification with rank, fame, and likes gained
        await _firestore.collection('notifications').doc(userId).set({
          'message': 'Your word "${wordDoc.id}" ranked $rank out of $totalPlayers players. '
                     'You gained $fame fame and $likes likes!',
          'timestamp': FieldValue.serverTimestamp(),
          'date': _currentDateKey,
        });

        // Optionally print the notification for debugging
        print('Notified user $userId: Rank: $rank, Fame: $fame, Likes: $likes');
      }
    }
  }

  Future<bool> submitDailyWord(String word) async {
    final user = _auth.currentUser;

    if (user == null || _hasSubmittedToday) {
      return false;
    }
    _hasSubmittedToday = true; // Set this immediately to prevent double submissions
    notifyListeners();

    final lowercaseWord = word.toLowerCase();
    final wordRef = _firestore
        .collection('daily_challenges')
        .doc(_currentDateKey)
        .collection('words')
        .doc(lowercaseWord);

    try {
      await _firestore.runTransaction((transaction) async {
        final wordDoc = await transaction.get(wordRef);
        if (wordDoc.exists) {
          transaction.update(wordRef, {'count': FieldValue.increment(1)});
        } else {
          transaction.set(wordRef, {'count': 1});
        }
      });

      await _firestore.collection('user_submissions').doc(user.uid).set({
        'word': lowercaseWord,
        'timestamp': FieldValue.serverTimestamp(),
        'date': _currentDateKey,
      });

      await _firestore.collection('users').doc(user.uid).update({
        'likes': FieldValue.increment(20),
        'lastSubmittedWord': lowercaseWord,
        'lastSubmissionDate': FieldValue.serverTimestamp(),
      });

      _hasSubmittedToday = true;
      await _updateUserScore(user.uid, lowercaseWord);

      notifyListeners();
      return true;
    } catch (e) {
      print("Error during word submission: $e");
      return false;
    }
  }

  Future<void> _updateUserScore(String userId, String word) async {
    final rank = await _getWordRank(word);
    final totalPlayers = await _getTotalPlayers();

    final fame = _calculateFame(totalPlayers, rank);
    final likes = fame * 10;

    await _firestore.collection('users').doc(userId).update({
      'fame': FieldValue.increment(fame),
      'likes': FieldValue.increment(likes),
    });
  }

  int _calculateFame(int totalPlayers, int rank) {
    double rawFame = 100 * sqrt(totalPlayers) * (1 / rank) * (1 + (totalPlayers / 1000));
    return (rawFame / 1000000).round() * 1000000;
  }

  Future<int> _getWordRank(String word) async {
    final snapshot = await _firestore.collection('daily_words')
      .orderBy('count', descending: true)
      .get();

    return snapshot.docs.indexWhere((doc) => doc.id == word) + 1;
  }

  Future<int> _getTotalPlayers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.size;
  }

  Future<List<Map<String, dynamic>>> getDailyLeaderboard() async {
    final snapshot = await _firestore
        .collection('daily_challenges')
        .doc(_currentDateKey)
        .collection('words')
        .orderBy('count', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => {
      'word': doc.id,
      'count': doc['count'],
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getOverallLeaderboard() async {
    final snapshot = await _firestore.collection('users')
      .orderBy('fame', descending: true)
      .limit(10)
      .get();

    return snapshot.docs.map((doc) => {
      'userId': doc.id,
      'displayName': doc['displayName'],
      'fame': doc['fame'],
    }).toList();
  }
    void triggerDailyResetManually() {
    print("Manually triggering daily reset...");
    _resetDaily();
  }
}