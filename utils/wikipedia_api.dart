import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaApi {
  static Future<String?> getWordDefinition(String word) async {
    final url = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$word');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['extract'];
    }
    return null;
  }
}
