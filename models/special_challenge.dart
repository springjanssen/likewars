import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialChallengeModel {
  String id;
  String word;
  int likesCost;
  bool isActive;

  SpecialChallengeModel({
    required this.id,
    required this.word,
    required this.likesCost,
    this.isActive = true,
  });

  factory SpecialChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpecialChallengeModel(
      id: doc.id,
      word: data['word'] ?? 'Unknown',
      likesCost: data['likesCost'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }
}
