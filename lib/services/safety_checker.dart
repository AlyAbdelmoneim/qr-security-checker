import 'dart:convert';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SafetyChecker {
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiUrl = 'https://safebrowsing.googleapis.com/v4/threatMatches:find';

  static Future<String?> checkUrlSafety(String url) async {
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
      if (responseData.containsKey('matches')) {
        return responseData['matches'][0]['threatType'];
      }
    }
    return null; // Safe
  }
}
