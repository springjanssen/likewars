import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/word_dictionary.dart';
import '../widgets/on_screen_keyboard.dart';
import '../widgets/countdown_timer_widget.dart';
import '../models/challenge_model.dart'; 
import '../models/player_model.dart'; // Ensure to import PlayerModel
import '../utils/word_validation.dart'; 

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({Key? key}) : super(key: key);

  @override
  _DailyChallengeScreenState createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final TextEditingController _wordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _submittedWord;
  String? _wordDescription;
  bool _isWordInvalid = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkSubmittedWord();
    // Schedule a new challenge after the current build
    _initializeChallenge();
  }

  Future<void> _initializeChallenge() async {
    final challengeModel = Provider.of<ChallengeModel>(context, listen: false);
    
    // Ensure we run the initialization after the current build frame
    Future.delayed(Duration.zero, () async {
      await challengeModel.scheduleNewChallenge(); 
      await challengeModel.saveToFirestore(); 
    });
  }

  Future<void> _checkSubmittedWord() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('user_submissions').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _submittedWord = doc.data()?['word'];
          _wordDescription = doc.data()?['description'];
        });
      }
    }
  }

  Future<void> _getWordDescription(String word) async {
    final description = await WordDictionary.getWordDescription(word);
    setState(() {
      _wordDescription = description;
    });
  }
   void _submitWord(ChallengeModel challengeModel) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final word = _wordController.text.trim();
    if (word.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        final isValid = await WordValidation.validateWord(word, challengeModel);
        setState(() {
          _isWordInvalid = !isValid;
        });

        if (isValid) {
          // Fetch the word description
          final description = await WordDictionary.getWordDescription(word);
        
          // Update state with the new word and its description
          setState(() {
            _submittedWord = word;
            _wordDescription = description;
          });

          // Get the player model
          final playerModel = Provider.of<PlayerModel>(context, listen: false);

          // Submit the word to the challenge model
          challengeModel.submitWord(word); // Update word submissions

          // Add submission to the player's submission history
          playerModel.addSubmission(word, Timestamp.now(), challengeModel.challengeId); // Pass challengeId

          // Save the updated player data to Firestore
          await FirebaseFirestore.instance
              .collection('players')
              .doc(playerModel.id) // Ensure the correct document ID
              .update(playerModel.toMap())
              .then((_) {
                  print("Player data updated successfully.");
              }).catchError((error) {
                  print("Error updating player data: $error");
              });

          // Save the updated challenge data back to Firestore
          await challengeModel.saveToFirestore();

          // Save the word and its description to Firestore
          await _firestore.collection('user_submissions').doc(user.uid).set({
            'word': word,
            'description': description,
            'timestamp': FieldValue.serverTimestamp(),
          });

          _wordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Word submitted successfully!')),
          );
        }
      }
    }

    setState(() => _isSubmitting = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Like Wars Daily Challenge'),
      ),
      body: Consumer<ChallengeModel>(
        builder: (context, challengeModel, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _submittedWord == null ? 'I like the word...' : 'I liked the word "$_submittedWord"',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 20),
                if (_submittedWord == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      controller: _wordController,
                      decoration: InputDecoration(
                        hintText: 'Enter your word',
                        border: OutlineInputBorder(),
                        errorText: _isWordInvalid ? 'Invalid word!' : null,
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                if (_submittedWord == null)
                  ElevatedButton(
                    onPressed: () => _submitWord(challengeModel),
                    child: Text('Submit Word'),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _showMeaningDialog(context, _wordDescription ?? 'No meaning available'),
                    child: Text('Show Word Meaning'),
                  ),
                SizedBox(height: 40),
                Text(
                  _submittedWord == null ? 'Next day challenge in:' : 'You have to wait for:',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: 20),
                CountdownTimerWidget(targetTime: challengeModel.endTime ?? DateTime.now()), // Using endTime directly
                if (_submittedWord == null)
                  Expanded(
                    child: OnScreenKeyboard(
                      onKeyPressed: (key) {
                        _wordController.text += key;
                        setState(() {
                          _isWordInvalid = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMeaningDialog(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Meaning of the Word'),
          content: SingleChildScrollView(
            child: Text(description, style: TextStyle(fontSize: 16)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}