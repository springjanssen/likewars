import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PlayerModel with ChangeNotifier {
  String id;
  String firstName;
  String lastName;
  String displayName;
  String photoURL;
  int likes;
  int fame;
  int coins;
  Timestamp lastLogin;
  int score;
  String? lastSubmittedWord;
  Timestamp? lastSubmissionDate;
  List<Map<String, dynamic>> submissionHistory; // To track word submissions over time

  PlayerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.photoURL,
    this.likes = 0,
    this.fame = 0,
    this.coins = 0,
    Timestamp? lastLogin,
    this.score = 0,
    this.lastSubmittedWord,
    this.lastSubmissionDate,
    List<Map<String, dynamic>>? submissionHistory, // Allow null and create a mutable list
  })  : submissionHistory = submissionHistory ?? [], // Ensure it's initialized as a mutable list
        lastLogin = lastLogin ?? Timestamp.now();

  // Factory method to create a PlayerModel from Firestore document
  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerModel(
      id: doc.id,
      firstName: data['firstName'] ?? 'Unknown',
      lastName: data['lastName'] ?? 'Unknown',
      displayName: data['displayName'] ?? 'Guest',
      photoURL: data['photoURL'] ?? '',
      likes: data['likes'] ?? 0,
      fame: data['fame'] ?? 0,
      coins: data['coins'] ?? 0,
      lastLogin: data['lastLogin'] ?? Timestamp.now(),
      score: data['score'] ?? 0,
      lastSubmittedWord: data['lastSubmittedWord'],
      lastSubmissionDate: data['lastSubmissionDate'],
      submissionHistory: List<Map<String, dynamic>>.from(data['submissionHistory'] ?? []), // Fetch submission history
    );
  }

  // Convert PlayerModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'photoURL': photoURL,
      'likes': likes,
      'fame': fame,
      'coins': coins,
      'lastLogin': lastLogin,
      'score': score,
      'lastSubmittedWord': lastSubmittedWord,
      'lastSubmissionDate': lastSubmissionDate,
      'submissionHistory': submissionHistory, // Store submission history
    };
  }

  // Method to fetch current player's submissions
  Future<void> fetchPlayerSubmissions() async {
    try {
      final playerDoc = await FirebaseFirestore.instance.collection('players').doc(id).get();
      final data = playerDoc.data() as Map<String, dynamic>;

      submissionHistory = List<Map<String, dynamic>>.from(data['submissionHistory'] ?? []);
      
      notifyListeners(); // Notify UI of changes
    } catch (e) {
      print("Error fetching submissions for player $id: $e");
    }
  }

  // Helper method to check if the player has submitted a word in the current 15 UTC to 15 UTC period
  bool hasSubmittedInCurrentPeriod(Timestamp currentDate) {
    if (lastSubmissionDate == null) return false;

    final lastSubmissionDateTime = lastSubmissionDate!.toDate().toUtc();
    final currentDateTime = currentDate.toDate().toUtc();

    // Calculate the start of the current 15 UTC to 15 UTC period
    var currentPeriodStart = DateTime.utc(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      15,
    );

    // Adjust for when the current time is before 15 UTC
    if (currentDateTime.hour < 15) {
      currentPeriodStart = currentPeriodStart.subtract(Duration(days: 1));
    }

    final currentPeriodEnd = currentPeriodStart.add(Duration(days: 1));

    // Check if the last submission is within the current period
    return lastSubmissionDateTime.isAfter(currentPeriodStart) &&
           lastSubmissionDateTime.isBefore(currentPeriodEnd);
  }

  // Method to add a word submission to the player's submission history
  bool addSubmission(String word, Timestamp date, String challengeId) {
    // Check if the player has already submitted a word in the current 15 UTC to 15 UTC period
    if (hasSubmittedInCurrentPeriod(date)) {
      print("Player has already submitted a word in the current 15 UTC to 15 UTC period.");
      return false; // Submission not allowed
    }

    // Create a new mutable list based on the current submissionHistory
    submissionHistory = List.from(submissionHistory)
      ..add({
        'word': word,
        'date': date,
        'challengeId': challengeId,
      });

    // Update last submitted word and date
    lastSubmittedWord = word;
    lastSubmissionDate = date;

    print("Added submission: Word='$word', Date='$date', ChallengeId='$challengeId'");
    print("Updated submission history: $submissionHistory");

    notifyListeners();
    return true; // Submission successful
  }

  // Helper method to check if the player has submitted a word today
  bool hasSubmittedToday(Timestamp currentDate) {
    if (lastSubmissionDate == null) return false;

    final lastSubmissionDateTime = lastSubmissionDate!.toDate();
    final currentDateTime = currentDate.toDate();

    return lastSubmissionDateTime.year == currentDateTime.year &&
           lastSubmissionDateTime.month == currentDateTime.month &&
           lastSubmissionDateTime.day == currentDateTime.day;
  }

  // Update the model based on the data from Firestore
  void updateFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    firstName = data['firstName'] ?? firstName;
    lastName = data['lastName'] ?? lastName;
    displayName = data['displayName'] ?? displayName;
    photoURL = data['photoURL'] ?? photoURL;
    likes = data['likes'] ?? likes;
    fame = data['fame'] ?? fame;
    coins = data['coins'] ?? coins;
    lastLogin = data['lastLogin'] ?? lastLogin;
    score = data['score'] ?? score;
    lastSubmittedWord = data['lastSubmittedWord'];
    lastSubmissionDate = data['lastSubmissionDate'];
    submissionHistory = List<Map<String, dynamic>>.from(data['submissionHistory'] ?? submissionHistory);

    notifyListeners();
  }

  // Helper method to update fame, likes, and coins
  void updateRewards({int addedFame = 0, int addedLikes = 0, int addedCoins = 0}) {
    // Update fame, likes, and coins
    fame += addedFame;
    likes += addedLikes;
    coins += addedCoins;

    notifyListeners(); // Notify the UI about the changes

    // Update Firestore with the new fame, likes, and coins values
    FirebaseFirestore.instance.collection('players').doc(id).update({
      'fame': fame,
      'likes': likes,
      'coins': coins,
    }).then((_) {
      print('Player $id successfully updated with $addedFame fame, $addedLikes likes, and $addedCoins coins.');
    }).catchError((error) {
      print('Failed to update player $id: $error');
    });
  }
  
}
