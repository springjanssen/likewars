import 'dart:convert';
import 'package:http/http.dart' as http;

class WordDictionary {
  static const String baseUrl = 'https://en.wiktionary.org/w/api.php';

  static Future<String> getWordDescription(String word) async {
    final url = '$baseUrl?action=query&format=json&prop=extracts&explaintext&titles=$word&origin=*';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final page = data['query']['pages'].values.first;

        if (page['extract'] != null) {
          return page['extract'];
        }
      }
    } catch (error) {
      print('Error fetching definition: $error');
    }
    return 'No relevant information found.';
  }
}
