import 'package:flutter/material.dart';
import 'package:security_checker/widgets/ar_overlay.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR AR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AROverlay(),
    );
  }
}
