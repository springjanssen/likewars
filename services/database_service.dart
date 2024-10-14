import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      } else {
        return null; // User not found
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Create a new user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      print(e);
    }
  }

  // ... (You can add other methods for updating user data, 
  // retrieving leaderboards, etc., as needed) ...
}