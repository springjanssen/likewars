import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ChallengeModel with ChangeNotifier {
  String challengeId = '';
  DateTime? startTime; // Made nullable for safer handling
  DateTime? endTime;   // Made nullable for safer handling
  Map<String, int> wordSubmissions = {}; // Initialized here to avoid null check later
  String? topWord;
  List<String> restrictedWords = []; // Tracks top words from past 30 days

  ChallengeModel({
    required this.challengeId,
    this.startTime,
    this.endTime,
    Map<String, int>? wordSubmissions,
    this.topWord,
  }) : wordSubmissions = wordSubmissions ?? {};

Future<void> checkAndScheduleChallenge() async {
  final now = DateTime.now().toUtc();
  var currentPeriodStart = DateTime.utc(now.year, now.month, now.day, 15); // 15 UTC start
  if (now.hour < 15) {
    currentPeriodStart = currentPeriodStart.subtract(Duration(days: 1));
  }
  final currentPeriodEnd = currentPeriodStart.add(Duration(days: 1)); // 24-hour period

  print("Current period: Start: $currentPeriodStart, End: $currentPeriodEnd");

  // Query challenges that overlap with this period
  final snapshot = await FirebaseFirestore.instance
      .collection('challenges')
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(currentPeriodStart))
      .where('startTime', isLessThan: Timestamp.fromDate(currentPeriodEnd))
      .limit(1)
      .get();

  print("Checking for existing challenges. Found: ${snapshot.docs.length}");

  if (snapshot.docs.isEmpty) {
    // No challenge exists within the period, create a new one
    print('No existing challenge found. Scheduling new challenge.');
    await scheduleNewChallenge();
    await saveToFirestore();
  } else {
    // A challenge exists, fetch and update it
    print('Existing challenge found: ${snapshot.docs.first.id}');
    await fetchChallenge(snapshot.docs.first);
  }
}

Future<void> scheduleNewChallenge() async {
  final now = DateTime.now().toUtc();
  startTime = DateTime.utc(now.year, now.month, now.day, 15);
  if (now.hour < 15) {
    startTime = startTime!.subtract(Duration(days: 1));
  }
  endTime = startTime!.add(Duration(days: 1));

  // Check if there's already an existing challenge
  final existingChallengeQuery = await FirebaseFirestore.instance
      .collection('challenges')
      .where('startTime', isEqualTo: startTime)
      .limit(1)
      .get();

  if (existingChallengeQuery.docs.isNotEmpty) {
    print('Challenge already exists for the period. Challenge ID: ${existingChallengeQuery.docs.first.id}');
    return; // Abort creation
  }

  // Proceed to create new challenge if no challenge exists for this period
  challengeId = FirebaseFirestore.instance.collection('challenges').doc().id;
  print('Creating new challenge with ID: $challengeId');
  notifyListeners();
}

  Future<void> fetchChallenge(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Set the challengeId to the fetched document's ID
    challengeId = doc.id;  // <-- Ensure this line is present
    
    startTime = data['startTime'].toDate();
    endTime = data['endTime'].toDate();
    wordSubmissions = Map<String, int>.from(data['wordSubmissions']);
    topWord = data['topWord'];
    await fetchRestrictedWords();
    
    notifyListeners(); // Notify once after all data is set
  }

  // Fetch restricted top words from last 30 days
  Future<void> fetchRestrictedWords() async {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    final querySnapshot = await FirebaseFirestore.instance
        .collection('challenges')
        .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
        .where('topWord', isNotEqualTo: null) // Optimizing by querying only docs with topWord
        .get();

    restrictedWords = querySnapshot.docs
        .map((doc) => doc['topWord'] as String)
        .toList();

    notifyListeners();
  }

  void submitWord(String word) {
    // Check if there’s an active challenge
    if (challengeId.isEmpty || startTime == null || endTime == null) {
      print('No active challenge to submit word to. Challenge ID: $challengeId');
      return;
    }
    
    if (restrictedWords.contains(word)) {
      print('This word was a top word in the last 30 days. Please choose another word.');
    } else {
      // Update existing challenge's word submissions
      wordSubmissions[word] = (wordSubmissions[word] ?? 0) + 1;
      print('Added submission: Word=$word, Challenge ID=$challengeId'); // Add this log
      saveToFirestore();  // Make sure to save after updating submissions!
      notifyListeners();
    }
  }


  // Get the top word based on submissions
  String getTopWord() {
    if (wordSubmissions.isEmpty) return '';
    return wordSubmissions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // End the challenge, calculate top word, and save results
  Future<void> endChallenge() async {
    await _finalizeChallenge();
  }

  // Prematurely conclude challenge and notify players
  Future<void> concludeChallengePrematurely() async {
    if (endTime != null && endTime!.isBefore(DateTime.now())) {
      print('Challenge has already ended.');
      return;
    }
    await _finalizeChallenge();
    notifyPlayersAboutPrematureEnd();
  }

// Finalize challenge, calculate top word, reward players
  Future<void> _finalizeChallenge() async {
    // Get the top word from submissions
    topWord = getTopWord();

    // Check if a top word was found
    if (topWord != null && topWord!.isNotEmpty) {
      await saveToFirestore(); // Save challenge results to Firestore
      await addToRestrictedWords(topWord!); // Add top word to restricted words
      print('Challenge ended! Top word: $topWord');

      // Call rewardPlayers to reward users based on their submissions
      await rewardPlayers(challengeId); // Use challengeId from the model
    } else {
      print('No top word was found.'); // Handle case where no top word exists
    }
  }

  // Add top word to restricted list for 30 days
  Future<void> addToRestrictedWords(String word) async {
    await FirebaseFirestore.instance.collection('restrictedWords').add({
      'word': word,
      'restrictedUntil': Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
    });
    restrictedWords.add(word);
    notifyListeners();
  }

  Future<void> saveToFirestore() async {
    if (challengeId.isEmpty) {
      print('Challenge ID is empty. Unable to save to Firestore.');
      return;
    }

    // Use the challengeId to update the current challenge
    await FirebaseFirestore.instance.collection('challenges').doc(challengeId).set({
      'startTime': startTime,
      'endTime': endTime,
      'wordSubmissions': wordSubmissions,
      'topWord': topWord,
    }, SetOptions(merge: true)); // <-- Important: merge with existing data!
  }

  void notifyPlayersAboutPrematureEnd() {
    // Hook up NotificationService here
    print('Players notified about the early end of the challenge!');
  }

  // Get top words sorted by submission count
  List<MapEntry<String, int>> getTopWords() {
    if (wordSubmissions.isEmpty) return [];
    var sortedEntries = wordSubmissions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries;
  }

  // Reward players based on their submission history against challenge submissions
  Future<void> rewardPlayers(String challengeId) async {
    // Fetch the challenge data with word submissions
    final challengeDoc = await FirebaseFirestore.instance.collection('challenges').doc(challengeId).get();
    
    if (!challengeDoc.exists) {
      print('Challenge document not found for ID: $challengeId');
      return;
    }

    final challengeData = challengeDoc.data() as Map<String, dynamic>;
    final wordSubmissions = Map<String, int>.from(challengeData['wordSubmissions'] ?? {});

    // Debug: Log the word submissions from the challenge
    print('Word submissions in challenge: $wordSubmissions');

    final playerDocs = await FirebaseFirestore.instance.collection('players').get();

    // Efficient player submission tracking
    final Map<String, Map<String, int>> playerSubmissions = {};

    for (var playerDoc in playerDocs.docs) {
      final playerId = playerDoc.id;
      final playerData = playerDoc.data() as Map<String, dynamic>;
      final submissionHistory = List<Map<String, dynamic>>.from(playerData['submissionHistory'] ?? []);

      // Track submissions against challenge submissions
      for (var submission in submissionHistory) {
        final submittedWord = submission['word'];
        if (wordSubmissions.containsKey(submittedWord)) {
          playerSubmissions[playerId] = playerSubmissions[playerId] ?? {};
          playerSubmissions[playerId]![submittedWord] = (playerSubmissions[playerId]![submittedWord] ?? 0) + 1;

          // Debug: Log each player's submission against the challenge
          print('Player $playerId submitted word: "$submittedWord". Count: ${playerSubmissions[playerId]![submittedWord]}');
        }
      }
    }

    // Debug: Log the player submissions
    print('Player submissions against challenge submissions: $playerSubmissions');

    // Calculate rewards
    for (var entry in playerSubmissions.entries) {
      final playerId = entry.key;
      final wordCounts = entry.value;

      for (var topEntry in wordCounts.entries) {
        final submittedWord = topEntry.key;
        final count = topEntry.value;
        final submissionCount = wordSubmissions[submittedWord]!;

        // Calculate fame and likes based on the word's submission count
        final rank = getRankForWord(wordSubmissions, submittedWord);
        final fame = _calculateFame(count, rank);
        final likes = fame * 10;

        // Debug: Log each player's reward details
        print('Rewarding player: $playerId, Word: "$submittedWord", Count: $count, Challenge Submission Count: $submissionCount, Rank: $rank, Fame: $fame, Likes: $likes');

        await rewardPlayer(playerId, fame, likes, rank, submittedWord, count);
      }
    }
  }

  // Fame calculation moved to its own function for easier tweaking
  int _calculateFame(int count, int rank) {
    final double rawFame = 100 * sqrt(count) * (1 / rank) * (1 + (count / 1000));

    // Debug: Log raw fame calculation
    print('Calculating fame: Count: $count, Rank: $rank, Raw Fame: $rawFame');

    return rawFame.round();
  }

  // Get rank for word based on its submission count
  int getRankForWord(Map<String, int> wordSubmissions, String word) {
    final sortedEntries = wordSubmissions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort in descending order
    for (int i = 0; i < sortedEntries.length; i++) {
      if (sortedEntries[i].key == word) return i + 1; // Rank is 1-based index
    }
    return 0;
  }

  // rewardPlayer function remains unchanged
  Future<void> rewardPlayer(String playerId, int fame, int likes, int rank, String word, int count) async {
    final playerRef = FirebaseFirestore.instance.collection('players').doc(playerId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final playerSnapshot = await transaction.get(playerRef);
      if (playerSnapshot.exists) {
        final playerData = playerSnapshot.data() as Map<String, dynamic>;
        final updatedFame = ((playerData['fame'] ?? 0) as num).toInt() + fame;
        final updatedLikes = ((playerData['likes'] ?? 0) as num).toInt() + likes;

        // Debug: Log the updates being made to the player data
        print('Updating player: $playerId, Updated Fame: $updatedFame, Updated Likes: $updatedLikes, Rank: $rank, Last Submitted Word: $word, Last Word Count: $count');

        transaction.update(playerRef, {
          'fame': updatedFame,
          'likes': updatedLikes,
          'lastRewardedRank': rank,
          'lastSubmittedWord': word,
          'lastWordCount': count,
        });
      } else {
        print('Player document not found for ID: $playerId');
      }
    });
  }
  }
