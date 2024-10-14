import 'package:flutter/material.dart';
import 'package:wikipedia_api/wikipedia_api.dart'; // Ensure this import is correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary Test',
      home: DictionaryTestScreen(),
    );
  }
}

class DictionaryTestScreen extends StatefulWidget {
  const DictionaryTestScreen({super.key});

  @override
  _DictionaryTestScreenState createState() => _DictionaryTestScreenState();
}

class _DictionaryTestScreenState extends State<DictionaryTestScreen> {
  final TextEditingController _wordController = TextEditingController();
  String? _wordMeaning;

  void _fetchWordMeaning(String word) async {
    final api = TransformsApi();
    final from = 'en'; // Source language code
    try {
      final result = await api.doDict(from, word);
      setState(() {
        _wordMeaning = result?.translations.first.phrase; // Adjust based on actual structure
      });
    } catch (e) {
      print('Exception when calling TransformsApi->doDict: $e');
      setState(() {
        _wordMeaning = 'Error fetching meaning.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dictionary Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _wordController,
              decoration: InputDecoration(hintText: 'Enter a word'),
            ),
            ElevatedButton(
              onPressed: () {
                final word = _wordController.text.trim();
                if (word.isNotEmpty) {
                  _fetchWordMeaning(word);
                }
              },
              child: Text('Get Meaning'),
            ),
            if (_wordMeaning != null) ...[
              SizedBox(height: 20),
              Text(_wordMeaning!),
            ],
          ],
        ),
      ),
    );
  }
}
