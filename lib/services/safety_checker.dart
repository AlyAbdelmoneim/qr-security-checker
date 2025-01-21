import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SafetyChecker {

  static const String apiKey = 'AIzaSyDDjzX3ZK-e0qiMkPyzu7pe6VBUBd4txoA';
  static const String apiUrl = 'https://safebrowsing.googleapis.com/v4/threatMatches:find';

  static Future<String?> checkUrlSafety(String url) async {
    try {
      // Prepare the request body
      final requestBody = {
        "client": {
          "clientId": "security-checker",
          "clientVersion": "1.0"
        },
        "threatInfo": {
          "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE", "POTENTIALLY_HARMFUL_APPLICATION"],
          "platformTypes": ["ANY_PLATFORM"],
          "threatEntryTypes": ["URL"],
          "threatEntries": [
            {"url": url}
          ]
        }
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if there are any matches
        if (responseData.containsKey('matches')) {
          // Extract the threat type from the first match
          final threatType = responseData['matches'][0]['threatType'];
          return threatType; // Return the threat type (e.g., "MALWARE")
        } else {
          // No threats found
          return null; // Return null to indicate the URL is safe
        }
      } else {
        // Handle API errors
        debugPrint('Safe Browsing API Error: ${response.statusCode} - ${response.body}');
        return 'API Error: ${response.statusCode}';
      }
    } catch (e) {
      // Handle exceptions
      debugPrint('Error checking URL safety: $e');
      return 'Exception: ${e.toString()}';
    }
  }
}