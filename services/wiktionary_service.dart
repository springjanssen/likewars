import 'dart:convert';
import 'package:http/http.dart' as http;

class WiktionaryService {
  Future<String> getDefinition(String word) async {
    final url = 'https://en.wiktionary.org/w/api.php?action=query&format=json&prop=extracts&explaintext&titles=$word&origin=*';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final page = data['query']['pages'].values.first;
        
        if (page['extract'] != null) {
          return page['extract'];
        } else {
          return 'No definition found for "$word".';
        }
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (error) {
      return 'Error fetching definition: $error';
    }
  }
}
