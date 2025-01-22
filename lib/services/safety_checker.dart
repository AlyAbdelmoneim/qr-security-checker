import 'dart:convert';
import 'package:http/http.dart' as http;

class SafetyChecker {
  static const String apiKey = 'AIzaSyDDjzX3ZK-e0qiMkPyzu7pe6VBUBd4txoA'; // Replace with your actual API key
  static const String apiUrl = 'https://safebrowsing.googleapis.com/v4/threatMatches:find';

  static Future<String> checkUrlSafety(String url) async {
    try {
      final requestBody = {
        "client": {"clientId": "your-app", "clientVersion": "1.0"},
        "threatInfo": {
          "threatTypes": [
            "MALWARE",
            "SOCIAL_ENGINEERING",
            "UNWANTED_SOFTWARE",
            "POTENTIALLY_HARMFUL_APPLICATION"
          ],
          "platformTypes": ["ANY_PLATFORM"],
          "threatEntryTypes": ["URL"],
          "threatEntries": [
            {"url": url}
          ],
        },
      };

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check for 'matches' key in the response
        if (responseData.containsKey('matches') && responseData['matches'].isNotEmpty) {
          final threatType = responseData['matches'][0]['threatType'];
          return 'Warning: $threatType detected!';
        } else {
          return 'The URL is safe';
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'API Error: Unable to verify URL safety';
      }
    } catch (e) {
      print('Exception while checking URL safety: $e');
      return 'Error: Could not verify URL safety';
    }
  }
}
