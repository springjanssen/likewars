import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  String uid;
  String email;
  String displayName;
  String? photoURL;
  int likes;
  int fame;
  int coins;
  DateTime? lastLogin;
  int score; // New field for daily challenge score
  String? lastSubmittedWord; // New field to track the last submitted word
  DateTime? lastSubmissionDate; // New field to track the last submission date

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.likes,
    required this.fame,
    required this.coins,
    this.lastLogin,
    this.score = 0, // Initialize score to 0
    this.lastSubmittedWord,
    this.lastSubmissionDate,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return UserModel(
      uid: snapshot.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      likes: data['likes'] ?? 0,
      fame: data['fame'] ?? 0,
      coins: data['coins'] ?? 0,
      lastLogin: data['lastLoginDate']?.toDate(),
      score: data['score'] ?? 0,
      lastSubmittedWord: data['lastSubmittedWord'],
      lastSubmissionDate: data['lastSubmissionDate']?.toDate(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'likes': likes,
      'fame': fame,
      'coins': coins,
      'lastLoginDate': lastLogin,
      'score': score,
      'lastSubmittedWord': lastSubmittedWord,
      'lastSubmissionDate': lastSubmissionDate,
    };
  }

  void updateFromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    uid = snapshot.id;
    email = data['email'] ?? '';
    displayName = data['displayName'] ?? '';
    photoURL = data['photoURL'];
    likes = data['likes'] ?? 0;
    fame = data['fame'] ?? 0;
    coins = data['coins'] ?? 0;
    lastLogin = data['lastLoginDate']?.toDate();
    score = data['score'] ?? 0;
    lastSubmittedWord = data['lastSubmittedWord'];
    lastSubmissionDate = data['lastSubmissionDate']?.toDate();
    score = data['score'] ?? 0;
    lastSubmittedWord = data['lastSubmittedWord'];
    lastSubmissionDate = data['lastSubmissionDate']?.toDate();
    
    notifyListeners(); // Notify listeners about changes
  }

  void updateScore(int newScore, int newFame, int newLikes) {
    score = newScore;
    fame += newFame;
    likes += newLikes;
    notifyListeners();
  }
}