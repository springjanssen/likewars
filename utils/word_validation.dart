import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import '../utils/word_dictionary.dart';

class WordValidation extends StatefulWidget {
  const WordValidation({Key? key}) : super(key: key);

  @override
  _WordValidationState createState() => _WordValidationState();

  // Static method to validate the word
  static Future<bool> validateWord(String word, ChallengeModel challenge) async {
    final description = await WordDictionary.getWordDescription(word);
    final isWordValid = description != 'No relevant information found.';
    final isWordRestricted = challenge.restrictedWords.contains(word);

    // Return true if the word is valid and not restricted
    return isWordValid && !isWordRestricted;
  }
}

class _WordValidationState extends State<WordValidation> {
  final TextEditingController _wordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _validationMessage;
  bool _isValidating = false;

  void _validateAndSubmitWord(ChallengeModel challengeModel) async {
    if (_isValidating) return; // Prevent multiple submissions at the same time
    setState(() => _isValidating = true);

    final word = _wordController.text.trim();
    if (word.isNotEmpty) {
      final isValid = await WordValidation.validateWord(word, challengeModel); // Use static validation method

      if (!isValid) {
        final description = await WordDictionary.getWordDescription(word);
        final isWordValid = description != 'No relevant information found.';
        final isWordRestricted = challengeModel.restrictedWords.contains(word);

        if (!isWordValid) {
          _validationMessage = 'Invalid word! Please enter a valid word.';
        } else if (isWordRestricted) {
          _validationMessage = 'This word was a top word in the last 30 days. Please choose another word.';
        }
      } else {
        // Submit the word if it's valid and not restricted
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('user_submissions').doc(user.uid).set({
            'word': word,
            'submittedAt': FieldValue.serverTimestamp(),
          });
          _validationMessage = 'Word submitted successfully!';
          _wordController.clear(); // Clear the input field
        }
      }

      setState(() {});
    }

    setState(() => _isValidating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Validation'),
      ),
      body: Consumer<ChallengeModel>(
        builder: (context, challengeModel, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _wordController,
                    decoration: InputDecoration(
                      hintText: 'Enter your word',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _validateAndSubmitWord(challengeModel),
                    child: Text('Submit Word'),
                  ),
                  SizedBox(height: 20),
                  if (_validationMessage != null)
                    Text(
                      _validationMessage!,
                      style: TextStyle(
                        color: _validationMessage!.startsWith('Invalid') || 
                                _validationMessage!.startsWith('This word') 
                          ? Colors.red 
                          : Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
