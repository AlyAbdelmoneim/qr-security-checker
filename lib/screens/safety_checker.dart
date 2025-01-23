// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class SafetyChecker {
//   static const String apiKey = 'AIzaSyDDjzX3ZK-e0qiMkPyzu7pe6VBUBd4txoA';
//   static const String apiUrl = 'https://safebrowsing.googleapis.com/v4/threatMatches:find';
//
//   static Future<String> checkUrlSafety(String url) async {
//     try {
//       final requestBody = {
//         "client": {"clientId": "your-app", "clientVersion": "1.0"},
//         "threatInfo": {
//           "threatTypes": [
//             "MALWARE",
//             "SOCIAL_ENGINEERING",
//             "UNWANTED_SOFTWARE",
//             "POTENTIALLY_HARMFUL_APPLICATION"
//           ],
//           "platformTypes": ["ANY_PLATFORM"],
//           "threatEntryTypes": ["URL"],
//           "threatEntries": [
//             {"url": url}
//           ],
//         },
//       };
//
//       final response = await http.post(
//         Uri.parse('$apiUrl?key=$apiKey'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData.containsKey('matches') && responseData['matches'].isNotEmpty) {
//           return 'Unsafe';
//         } else {
//           return 'Safe';
//         }
//       } else {
//         return 'API Error: Unable to verify URL safety';
//       }
//     } catch (e) {
//       return 'Error: Could not verify URL safety';
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class SafetyChecker {
  static const String apiKey = 'AIzaSyDDjzX3ZK-e0qiMkPyzu7pe6VBUBd4txoA';
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

        if (responseData.containsKey('matches') && responseData['matches'].isNotEmpty) {
          return 'Warning: Threat detected!';
        } else {
          return 'The URL is safe';
        }
      } else {
        return 'Error: API response error';
      }
    } catch (e) {
      return 'Error: Unable to check URL';
    }
  }
}
