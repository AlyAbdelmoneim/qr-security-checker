import 'package:flutter/material.dart';
import '../widgets/ar_overlay.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Safety Checker")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the AR screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AROverlay(),
              ),
            );
          },
          child: Text("Start AR Scan"),
        ),
      ),
    );
  }
}
