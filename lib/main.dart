import 'package:flutter/material.dart';
import 'package:security_checker/screens/ar_screen.dart';
import 'screens/qr_scanner_screen.dart';

void main() {
  runApp(const SecurityCheckerApp());
}

class SecurityCheckerApp extends StatefulWidget {
  const SecurityCheckerApp({Key? key}) : super(key: key);

  @override
  State<SecurityCheckerApp> createState() => _SecurityCheckerAppState();
}

class _SecurityCheckerAppState extends State<SecurityCheckerApp> {
  Key appKey = UniqueKey(); // Key for restarting the app

  // Function to restart the app
  void restartApp() {
    setState(() {
      appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: appKey, // Assign a unique key to restart the app
      debugShowCheckedModeBanner: false,
      title: 'QR AR Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => QRScannerScreen(onRestart: restartApp),
        '/arScreen': (context) => ARScreen(onRestart: restartApp),
      },
    );
  }
}
