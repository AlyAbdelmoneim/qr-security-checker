import 'package:flutter/material.dart';
import 'package:security_checker/widgets/ar_overlay.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR AR Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AROverlay(), // Set AR overlay as the initial screen
    );
  }
}
