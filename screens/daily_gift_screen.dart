import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyGiftScreen extends StatefulWidget {
  const DailyGiftScreen({super.key});

  @override
  _DailyGiftScreenState createState() => _DailyGiftScreenState();
}

class _DailyGiftScreenState extends State<DailyGiftScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAndGrantDailyGift();
  }

  Future<void> _checkAndGrantDailyGift() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          DateTime? lastLoginDate = userData?['lastLoginDate']?.toDate();
          final today = DateTime.now();

          if (lastLoginDate == null || !isSameDay(lastLoginDate, today)) {
            await _firestore.collection('users').doc(user.uid).update({
              'likes': FieldValue.increment(20),
              'lastLoginDate': today,
            });

            _showDialog('Daily Gift', 'You have received your daily gift of 20 likes!');
          }
        }
      }
    } catch (e) {
      _showDialog('Error', 'An error occurred while granting the daily gift.');
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Gift'),
      ),
      body: const Center(
        child: Text('You have been awarded your daily gift'),
      ),
    );
  }
}
