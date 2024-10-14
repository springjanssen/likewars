import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import '../models/player_model.dart';
import '../widgets/countdown_timer_widget.dart';

class ChallengeMode extends StatefulWidget {
  const ChallengeMode({Key? key}) : super(key: key);

  @override
  _ChallengeModeState createState() => _ChallengeModeState();
}

class _ChallengeModeState extends State<ChallengeMode> {
  final TextEditingController _wordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = Provider.of<ChallengeModel>(context);
    final player = Provider.of<PlayerModel>(context);

    // Check if the player has already submitted for this challenge
    bool hasAlreadySubmitted = player.submissionHistory.any(
      (submission) => submission['challengeId'] == challenge.challengeId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Challenge Mode - Submit Your Word!'),
            SizedBox(height: 20),

            // Check if the player has already submitted a word
            if (!hasAlreadySubmitted) ...[
              // Show the text field for word submission
              TextField(
                controller: _wordController,
                decoration: InputDecoration(
                  hintText: 'Enter your word',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitWord(challenge, player),
                child: _isSubmitting
                    ? CircularProgressIndicator() // Disable button and show loader when submitting
                    : Text('Submit Word'),
              ),
            ] else ...[
              // Show message after word submission
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'You have already submitted a word for this challenge!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: null,
                child: Text('You cannot submit again!'),
              ),
            ],

            SizedBox(height: 40),

            // Display current challenge information
            Text('Current Challenge: ${challenge.challengeId}'),
            SizedBox(height: 20),

            // Countdown Timer
            CountdownTimerWidget(targetTime: challenge.endTime ?? DateTime.now()),
          ],
        ),
      ),
    );
  }

  void _submitWord(ChallengeModel challenge, PlayerModel player) async {
    if (_isSubmitting) return; // Prevent multiple submissions at the same time
    setState(() => _isSubmitting = true);

    final word = _wordController.text.trim();

    // Validate submission conditions
    if (word.isNotEmpty) {
      if (!challenge.restrictedWords.contains(word)) {
        // Add submission to player with challengeId
        bool submissionSuccess = player.addSubmission(word, Timestamp.now(), challenge.challengeId);

        if (submissionSuccess) {
          // Save player's submission history to Firestore
          await FirebaseFirestore.instance
              .collection('players')
              .doc(player.id)
              .update(player.toMap());

          // Submit word to challenge
          challenge.submitWord(word);
          await challenge.saveToFirestore();

          // Clear the text field and show confirmation
          _wordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Word submitted successfully!')),
          );
        } else {
          // If submission fails, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have already submitted a word for this challenge!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This word is restricted! Please choose another.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid word!')),
      );
    }

    setState(() => _isSubmitting = false);
  }
}
