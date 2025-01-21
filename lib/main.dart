import 'package:flutter/material.dart';
import 'package:security_checker/screens/home_screen.dart';
import 'package:security_checker/services/safety_checker.dart';

void main() {
  runApp(const MainApp());
  SafetyChecker.checkUrlSafety('http://testsafebrowsing.appspot.com/s/phishing.html').then((response) {
    if (response == null) print('URL is safe');
    else print('URL Safety Check Response: $response');
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: HomeScreen(),
        ),
      ),
    );
  }
}
