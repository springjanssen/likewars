import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheatPage extends StatefulWidget {
  const CheatPage({Key? key}) : super(key: key);

  @override
  _CheatPageState createState() => _CheatPageState();
}

class _CheatPageState extends State<CheatPage> {
  final TextEditingController _likesController = TextEditingController();
  final TextEditingController _coinsController = TextEditingController();
  final TextEditingController _fameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  String? _errorMessage;

  Future<void> _updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user == null) {
        setState(() {
          _errorMessage = 'No user is currently logged in.';
        });
        return;
      }

      final likes = int.tryParse(_likesController.text) ?? 0;
      final coins = int.tryParse(_coinsController.text) ?? 0;
      final fame = int.tryParse(_fameController.text) ?? 0;
      final displayName = _displayNameController.text;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'likes': likes,
        'coins': coins,
        'fame': fame,
        'displayName': displayName.isNotEmpty ? displayName : FieldValue.delete(),
      });

      setState(() {
        _errorMessage = 'User data updated successfully!';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update user data: $e';
      });
    }
  }

  @override
  void dispose() {
    _likesController.dispose();
    _coinsController.dispose();
    _fameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cheat Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _likesController,
              decoration: const InputDecoration(
                labelText: 'Likes',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _coinsController,
              decoration: const InputDecoration(
                labelText: 'Coins',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fameController,
              decoration: const InputDecoration(
                labelText: 'Fame',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('Update User Data'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
