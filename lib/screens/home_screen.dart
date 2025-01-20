import 'package:flutter/material.dart';
import '../services/ar_service.dart';
import 'package:security_checker/widgets/ar_overlay.dart';

class HomeScreen extends StatelessWidget {
  final ARService arService = ARService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Safety Checker")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Open the AR screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AROverlay(controller: arService.arCoreController),
              ),
            );
          },
          child: Text("Start AR Scan"),
        ),
      ),
    );
  }
}
